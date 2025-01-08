import CloudKit
import Combine

class CloudManager: ObservableObject {
    static let shared = CloudManager()
    
    private let container = CKContainer.default()
    private let database: CKDatabase
    
    init() {
        self.database = container.privateCloudDatabase
    }
    
    func saveDeviceToken(_ token: String, completion: @escaping (Error?) -> Void) {
        let record = CKRecord(recordType: "Device")
        record["token"] = token
        record["lastSync"] = Date()
        
        database.save(record) { _, error in
            completion(error)
        }
    }
    
    func syncSites(completion: @escaping (Error?) -> Void) {
        // Implementar sincronización de sitios
        // Este método se llamará cuando se añadan o modifiquen sitios
    }
    
    func setupSubscriptions() {
        // Configurar suscripciones para cambios en la base de datos
        let subscription = CKQuerySubscription(
            recordType: "AuthRequest",
            predicate: NSPredicate(value: true),
            options: .firesOnRecordCreation
        )
        
        let notification = CKSubscription.NotificationInfo()
        notification.shouldSendContentAvailable = true
        subscription.notificationInfo = notification
        
        database.save(subscription) { _, error in
            if let error = error {
                print("Error configurando suscripción: \(error)")
            }
        }
    }
} 