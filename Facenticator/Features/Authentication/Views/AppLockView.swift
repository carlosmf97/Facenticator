import SwiftUI
import LocalAuthentication

struct AppLockView: View {
    @StateObject private var biometricManager = BiometricManager.shared
    @StateObject private var faceManager = FaceRegistrationManager.shared
    @State private var showingAlert = false
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "lock.shield")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.Colors.primary)
            
            Text("Autenticación requerida")
                .font(AppTheme.Typography.title)
            
            Text("Por favor, autentícate para acceder")
                .font(AppTheme.Typography.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                authenticate()
            } label: {
                HStack {
                    Image(systemName: "faceid")
                    Text("Autenticar")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.Colors.primary)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            if !faceManager.isRegistered {
                Button {
                    // Mostrar vista de registro
                } label: {
                    Text("Registrar gestos faciales")
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
        }
        .padding()
        .alert("Error de autenticación", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("No se pudo verificar tu identidad. Por favor, intenta de nuevo.")
        }
    }
    
    private func authenticate() {
        biometricManager.authenticateWithBiometrics { success in
            if !success {
                showingAlert = true
            }
        }
    }
} 
