import SwiftUI
import ARKit

struct ARViewContainer: UIViewRepresentable {
    let session: ARSession
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        arView.session = session
        arView.automaticallyUpdatesLighting = true
        
        // Configurar la vista de la cámara
        arView.backgroundColor = .black
        
        // Ocultar elementos de debug de AR
        arView.showsStatistics = false
        arView.debugOptions = []
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // No necesitamos actualizar la vista después de crearla
    }
} 