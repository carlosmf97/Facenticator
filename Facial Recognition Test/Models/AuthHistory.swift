import Foundation

struct AuthHistory: Identifiable, Codable {
    let id: UUID
    let siteId: String
    let siteName: String
    let timestamp: Date
    let success: Bool
    let failureReason: FailureReason?
    
    enum FailureReason: String, Codable {
        case timeout
        case wrongGesture
        case livenessCheckFailed
        case faceIdMismatch
        case tooManyAttempts
    }
} 