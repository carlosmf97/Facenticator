import Foundation

enum AuthorizationLevel: String, Codable, CaseIterable {
    case simple = "simple"           // Aprobar/Denegar
    case copy = "copy"              // Copiar y pegar código
    case manual = "manual"          // Introducir código
    case biometric = "biometric"    // FaceID + gesto
    
    var icon: String {
        switch self {
        case .simple: return "checkmark.shield.fill"
        case .copy: return "doc.on.doc.fill"
        case .manual: return "keyboard"
        case .biometric: return "faceid"
        }
    }
    
    var description: String {
        switch self {
        case .simple: return "Aprobación Simple"
        case .copy: return "Copiar Código"
        case .manual: return "Código Manual"
        case .biometric: return "Verificación Facial"
        }
    }
} 