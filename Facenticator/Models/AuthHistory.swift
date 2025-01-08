import Foundation

struct AuthHistory: Identifiable, Codable {
    let id: UUID
    let siteId: UUID
    let siteName: String
    let siteIssuer: String
    let timestamp: Date
    let success: Bool
    let failureReason: String?
    
    init(
        id: UUID = UUID(),
        siteId: UUID,
        siteName: String,
        siteIssuer: String,
        success: Bool,
        failureReason: String? = nil
    ) {
        self.id = id
        self.siteId = siteId
        self.siteName = siteName
        self.siteIssuer = siteIssuer
        self.timestamp = Date()
        self.success = success
        self.failureReason = failureReason
    }
} 