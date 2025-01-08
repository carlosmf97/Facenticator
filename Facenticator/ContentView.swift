import SwiftUI

struct ContentView: View {
    @StateObject private var biometricManager = BiometricManager.shared
    @StateObject private var faceManager = FaceRegistrationManager.shared
    
    var body: some View {
        Group {
            if !faceManager.isRegistered {
                FaceRegistrationView()
            } else if !biometricManager.isAuthenticated {
                AppLockView()
            } else {
                MainTabView()
            }
        }
    }
} 