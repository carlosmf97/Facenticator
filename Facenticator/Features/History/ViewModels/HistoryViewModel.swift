import SwiftUI
import CoreData
import Combine

class HistoryViewModel: ObservableObject {
    @Published var historyItems: [HistoryItem] = []
    @Published var searchText = ""
    
    private var context: NSManagedObjectContext
    
    var filteredItems: [HistoryItem] {
        if searchText.isEmpty {
            return historyItems
        }
        return historyItems.filter { item in
            item.siteName?.localizedCaseInsensitiveContains(searchText) == true ||
            item.siteIssuer?.localizedCaseInsensitiveContains(searchText) == true
        }
    }
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        loadHistory()
        
        // Si no hay historial, creamos datos dummy y recargamos
        if historyItems.isEmpty {
            print("Creando datos dummy para el historial...")
            DummyData.createDummyHistory(context: context)
            loadHistory()
        }
    }
    
    func loadHistory() {
        let request = NSFetchRequest<HistoryItem>(entityName: "HistoryItem")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \HistoryItem.timestamp, ascending: false)]
        
        do {
            historyItems = try context.fetch(request)
            print("Cargados \(historyItems.count) items del historial")
        } catch {
            print("Error cargando historial: \(error)")
        }
    }
    
    func deleteItems(at indexSet: IndexSet) {
        for index in indexSet {
            let item = historyItems[index]
            context.delete(item)
        }
        
        do {
            try context.save()
            loadHistory()
        } catch {
            print("Error eliminando items: \(error)")
        }
    }
    
    func clearHistory() {
        // Eliminar todos los items del historial
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = HistoryItem.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            historyItems.removeAll()
        } catch {
            print("Error borrando historial: \(error)")
        }
    }
}
