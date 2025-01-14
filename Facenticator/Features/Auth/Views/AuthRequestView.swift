import SwiftUI
import SDWebImageSwiftUI

struct AuthRequestView: View {
    let site: Site
    @Binding var isPresented: Bool
    @StateObject private var faceManager = FaceRegistrationManager.shared
    
    var body: some View {
        VStack {
            if let logoUrl = site.logoUrl {
                WebImage(url: URL(string: logoUrl))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }
            
            Text("Verificar acceso a \(site.name ?? "")")
                .font(.title2)
                .padding()
            
            // Mostrar la vista de verificación facial
            FaceRegistrationView()
                .onAppear {
                    // Iniciar verificación, no registro
                    faceManager.startVerification()
                }
                .onChange(of: faceManager.registrationProgress) { progress in
                    if progress >= 1.0 {
                        // Verificación exitosa
                        HapticManager.shared.notification(type: .success)
                        withAnimation {
                            isPresented = false
                        }
                    }
                }
        }
    }
}
