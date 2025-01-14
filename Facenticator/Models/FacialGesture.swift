enum FacialGesture: String, CaseIterable {
    case smile
    case eyebrows
    case openMouth
    case leftEyeWink
    case rightEyeWink
    
    static var registrationGestures: [FacialGesture] {
        [.smile, .eyebrows, .openMouth, .leftEyeWink, .rightEyeWink]
    }
    
    var description: String {
        switch self {
        case .smile:
            return "Sonríe naturalmente"
        case .eyebrows:
            return "Levanta las cejas"
        case .openMouth:
            return "Abre la boca"
        case .leftEyeWink:
            return "Guiña el ojo derecho"
        case .rightEyeWink:
            return "Guiña el ojo izquierdo"
        }
    }
    
    var icon: String {
        switch self {
        case .smile:
            return "face.smiling"
        case .eyebrows:
            return "face.dashed"
        case .openMouth:
            return "mouth"
        case .leftEyeWink:
            return "eye.slash"
        case .rightEyeWink:
            return "eye.slash"
        }
    }
} 