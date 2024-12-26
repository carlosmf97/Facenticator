import LocalAuthentication
import Combine

class BiometricService: ObservableObject {
    @Published private(set) var biometricType: BiometricType = .none
    @Published private(set) var isAuthenticated = false
    
    enum BiometricType {
        case none
        case faceID
        case touchID
    }
    
    enum BiometricError: LocalizedError {
        case authenticationFailed
        case biometryNotAvailable
        case biometryNotEnrolled
        case noFaceIDEnrolled
        
        var errorDescription: String? {
            switch self {
            case .authenticationFailed:
                return "No se pudo verificar tu identidad"
            case .biometryNotAvailable:
                return "La autenticación biométrica no está disponible"
            case .biometryNotEnrolled:
                return "No hay datos biométricos registrados"
            case .noFaceIDEnrolled:
                return "Face ID es necesario para usar esta app"
            }
        }
    }
    
    init() {
        biometricType = getBiometricType()
    }
    
    private func getBiometricType() -> BiometricType {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        default:
            return .none
        }
    }
    
    func authenticateUser() async throws {
        guard biometricType == .faceID else {
            throw BiometricError.noFaceIDEnrolled
        }
        
        let context = LAContext()
        let reason = "Verifica tu identidad para continuar"
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            
            await MainActor.run {
                self.isAuthenticated = success
            }
            
            if !success {
                throw BiometricError.authenticationFailed
            }
        } catch let error as LAError {
            throw self.convertLAErrorToBiometricError(error)
        }
    }
    
    private func convertLAErrorToBiometricError(_ error: LAError) -> BiometricError {
        switch error.code {
        case .biometryNotAvailable:
            return .biometryNotAvailable
        case .biometryNotEnrolled:
            return .biometryNotEnrolled
        default:
            return .authenticationFailed
        }
    }
} 