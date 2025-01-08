import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    
    var container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "AuthenticatorModel")
        
        guard let modelURL = Bundle.main.url(forResource: "AuthenticatorModel", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("No se pudo cargar el modelo de Core Data")
        }
        
        container = NSPersistentContainer(name: "AuthenticatorModel", managedObjectModel: model)
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error cargando Core Data: \(error.localizedDescription)")
                fatalError("Error cargando Core Data: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error guardando contexto: \(error)")
            }
        }
    }
} 


extension PersistenceController {
    func deleteAll() {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "HistoryItem")
        
        do {
            let items = try context.fetch(fetchRequest)
            for case let item as NSManagedObject in items {
                context.delete(item)
            }
            try context.save()
        } catch {
            print("Error borrando datos: \(error)")
        }
    }
}