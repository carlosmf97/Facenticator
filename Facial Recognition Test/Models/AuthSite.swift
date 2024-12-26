import Foundation
import CloudKit

struct AuthSite: Identifiable, Codable {
    let id: String
    let name: String
    let issuer: String
    let secret: String
    let createdAt: Date
    let lastUsed: Date?
    
    // CloudKit record conversion
    var record: CKRecord {
        let record = CKRecord(recordType: "AuthSite")
        record["id"] = id
        record["name"] = name
        record["issuer"] = issuer
        record["createdAt"] = createdAt
        record["lastUsed"] = lastUsed
        return record
    }
    
    // Inicializador desde CKRecord
    init?(from record: CKRecord) {
        guard let id = record["id"] as? String,
              let name = record["name"] as? String,
              let issuer = record["issuer"] as? String,
              let createdAt = record["createdAt"] as? Date else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.issuer = issuer
        self.createdAt = createdAt
        self.lastUsed = record["lastUsed"] as? Date
        self.secret = "" // El secreto se maneja por separado en Keychain
    }
    
    // Inicializador normal
    init(id: String, name: String, issuer: String, secret: String, createdAt: Date, lastUsed: Date?) {
        self.id = id
        self.name = name
        self.issuer = issuer
        self.secret = secret
        self.createdAt = createdAt
        self.lastUsed = lastUsed
    }
}
