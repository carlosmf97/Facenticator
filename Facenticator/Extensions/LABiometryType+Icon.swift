import LocalAuthentication

extension LABiometryType {
    var iconName: String {
        switch self {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "person.fill"
        }
    }
} 