import SwiftUI
import ARKit

struct FaceAuthView: View {
    @StateObject private var viewModel: FaceAuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(site: AuthSite) {
        _viewModel = StateObject(wrappedValue: FaceAuthViewModel(site: site))
    }
    
    var body: some View {
        ZStack {
            // Vista de cámara AR
            ARViewContainer(session: viewModel.arSession)
                .edgesIgnoringSafeArea(.all)
            
            // Overlay de UI
            VStack {
                // Header con título
                HStack {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(viewModel.timeRemaining)s")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(viewModel.timeRemaining <= 10 ? .red : .white)
                }
                .padding()
                .background(.ultraThinMaterial)
                
                Spacer()
                
                // Instrucciones del gesto
                if let currentGesture = viewModel.currentGesture {
                    VStack(spacing: 16) {
                        Text(currentGesture.rawValue)
                            .font(.title2)
                            .foregroundColor(.white)
                        Text(currentGesture.instructions)
                            .font(.body)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            viewModel.startAuthentication()
        }
        .alert("Autenticación Fallida", isPresented: $viewModel.showingError) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}
