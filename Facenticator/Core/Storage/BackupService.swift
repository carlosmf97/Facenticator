import Foundation
import CoreData

class BackupService {
    static let shared = BackupService()
    
    private let fileManager = FileManager.default
    
    func createBackup() throws -> URL {
        let context = PersistenceController.shared.container.viewContext
        
        // Obtener los sitios
        let siteFetch = NSFetchRequest<Site>(entityName: "Site")
        let sites = try context.fetch(siteFetch)
        
        // Convertir a datos serializables
        let backupData = sites.map { site in
            return [
                "id": site.id?.uuidString,
                "name": site.name,
                "issuer": site.issuer,
                "secret": site.secret,
                "createdAt": site.createdAt?.timeIntervalSince1970 ?? 0,
                "lastUsed": site.lastUsed?.timeIntervalSince1970 ?? 0
            ]
        }
        
        // Crear archivo de backup
        let documentsDirectory = try fileManager.url(for: .documentDirectory,
                                                   in: .userDomainMask,
                                                   appropriateFor: nil,
                                                   create: true)
        
        let backupURL = documentsDirectory.appendingPathComponent("authenticator_backup.json")
        let jsonData = try JSONSerialization.data(withJSONObject: backupData, options: .prettyPrinted)
        try jsonData.write(to: backupURL)
        
        return backupURL
    }
    
    func restoreBackup(from url: URL) throws {
        let jsonData = try Data(contentsOf: url)
        let backupData = try JSONSerialization.jsonObject(with: jsonData) as! [[String: Any]]
        
        let context = PersistenceController.shared.container.viewContext
        
        // Eliminar datos existentes
        let batchDelete = NSBatchDeleteRequest(fetchRequest: Site.fetchRequest())
        try context.execute(batchDelete)
        
        // Restaurar sitios
        for siteData in backupData {
            let site = Site(context: context)
            site.id = UUID(uuidString: siteData["id"] as! String)
            site.name = siteData["name"] as? String
            site.issuer = siteData["issuer"] as? String
            site.secret = siteData["secret"] as? String
            site.createdAt = Date(timeIntervalSince1970: siteData["createdAt"] as! TimeInterval)
            site.lastUsed = Date(timeIntervalSince1970: siteData["lastUsed"] as! TimeInterval)
        }
        
        try context.save()
    }
} 
