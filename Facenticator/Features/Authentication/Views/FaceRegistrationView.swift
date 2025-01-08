import SwiftUI
import ARKit

struct FaceRegistrationView: View {
    @StateObject private var registrationManager = FaceRegistrationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            ARViewContainer(session: registrationManager.arSession)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text(registrationManager.isVerificationMode ? "Verificación Facial" : "Registro Facial")
                    .font(AppTheme.Typography.title)
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
                
                if let gesture = registrationManager.currentGesture {
                    VStack(spacing: 20) {
                        Image(systemName: gesture.icon)
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        
                        Text(gesture.description)
                            .font(AppTheme.Typography.title3)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                }
                
                ProgressView(value: registrationManager.registrationProgress)
                    .progressViewStyle(.linear)
                    .tint(.white)
                    .padding()
                
                Text(registrationManager.registrationStatus)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(.white)
                    .padding()
            }
        }
        .onAppear {
            registrationManager.startRegistration()
        }
        .onDisappear {
            registrationManager.stopTracking()
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    let session: ARSession
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        arView.session = session
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
} 
