import Foundation

public enum FacialGesture: String, CaseIterable, Codable {
    case smile = "Sonríe naturalmente 😊"
    case openMouth = "Abre la boca suavemente 😮"
    case rightEyeWink = "Guiño derecho 😉"
    case leftEyeWink = "Guiño izquierdo 😉"
    case kissing = "Gesto de beso 😘"
    
    var instructions: String {
        switch self {
        case .smile:
            return "Sonríe de forma natural, como en una foto"
        case .openMouth:
            return "Abre la boca ligeramente, como diciendo 'ah'"
        case .rightEyeWink:
            return "Guiña el ojo derecho manteniendo el izquierdo abierto"
        case .leftEyeWink:
            return "Guiña el ojo izquierdo manteniendo el derecho abierto"
        case .kissing:
            return "Haz un gesto de beso suave"
        }
    }
    
    var securityWeight: Double {
        switch self {
        case .smile: return 0.7
        case .openMouth: return 0.8
        case .rightEyeWink, .leftEyeWink: return 0.9
        case .kissing: return 0.85
        }
    }
}