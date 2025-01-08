import LocalAuthentication
import SwiftUI

class BiometricManager: NSObject, ObservableObject {
    static let shared = BiometricManager()
    
    @Published var isAuthenticated: Bool {
        didSet {
            if !isAuthenticated {
                TOTPGenerator.shared.clearCache()
            }
        }
    }
    
    @Published var skipVerificationIntro: Bool {
        didSet {
            UserDefaults.standard.set(skipVerificationIntro, forKey: "skipVerificationIntro")
        }
    }
    
    var biometricType: LABiometryType {
        var type = LABiometryType.none
        let context = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            type = context.biometryType
        }
        
        return type
    }
    
    private override init() {
        self.isAuthenticated = false
        self.skipVerificationIntro = UserDefaults.standard.bool(forKey: "skipVerificationIntro")
        super.init()
    }
    
    func authenticateWithBiometrics(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Autenticación necesaria para acceder a la app"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.isAuthenticated = true
                    }
                    completion(success)
                }
            }
        } else {
            completion(false)
        }
    }
    
    func logout() {
        self.isAuthenticated = false
    }
} 