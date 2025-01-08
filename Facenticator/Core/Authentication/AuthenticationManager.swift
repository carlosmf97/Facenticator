import LocalAuthentication

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var isAuthenticated = false
    
    private init() {}
    
    func authenticateUser(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                 localizedReason: "Autenticar para acceder") { success, error in
                DispatchQueue.main.async {
                    self.isAuthenticated = success
                    completion(success)
                }
            }
        } else {
            completion(false)
        }
    }
} 