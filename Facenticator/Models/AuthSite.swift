import Foundation

struct AuthSite: Identifiable, Codable {
    let id: UUID
    let name: String
    let issuer: String
    let secret: String
    let createdAt: Date
    var lastUsed: Date?
    
    init(id: UUID = UUID(), name: String, issuer: String, secret: String) {
        self.id = id
        self.name = name
        self.issuer = issuer
        self.secret = secret
        self.createdAt = Date()
    }
} 