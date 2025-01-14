import SwiftUI

struct VerificationIntroView: View {
    let site: Site
    @Binding var showVerification: Bool
    @Binding var showAuthRequest: Bool
    @StateObject private var biometricManager = BiometricManager.shared
    @State private var dontShowAgain = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Icono animado
                LottieView(name: "face-scan")
                    .frame(width: 200, height: 200)
                
                VStack(alignment: .leading, spacing: 15) {
                    InstructionRow(icon: "checkmark.shield.fill",
                                 text: "Asegúrate de estar en un lugar bien iluminado")
                    
                    InstructionRow(icon: "face.smiling.fill",
                                 text: "Mantén tu rostro dentro del marco")
                    
                    InstructionRow(icon: "person.fill.viewfinder",
                                 text: "Sigue las instrucciones de gestos faciales")
                }
                .padding()
                
                Toggle("No volver a mostrar estas instrucciones", isOn: $dontShowAgain)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                Button {
                    if dontShowAgain {
                        biometricManager.skipVerificationIntro = true
                    }
                    showVerification = false
                    showAuthRequest = true
                } label: {
                    Text("Comenzar Verificación")
                        .font(AppTheme.Typography.title3)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Button {
                    showVerification = false
                } label: {
                    Text("Cancelar")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

struct InstructionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.Colors.primary)
                .font(.system(size: 24))
            
            Text(text)
                .font(AppTheme.Typography.body)
        }
    }
}

// Si no tienes LottieView, puedes usar esta versión simplificada:
struct LottieView: View {
    let name: String
    
    var body: some View {
        Image(systemName: "faceid")
            .font(.system(size: 100))
            .foregroundColor(AppTheme.Colors.primary)
    }
} 
