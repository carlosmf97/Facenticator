import SwiftUI
import ARKit

class FaceAuthViewModel: NSObject, ObservableObject {
    @Published var timeRemaining = 30
    @Published var currentGesture: FacialGesture?
    @Published var showingError = false
    @Published var errorMessage = ""
    
    let arSession = ARSession()
    private let site: AuthSite
    private let livenessDetector = LivenessDetector()
    private var timer: Timer?
    
    init(site: AuthSite) {
        self.site = site
        super.init()
        arSession.delegate = self
    }
    
    func startAuthentication() {
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Este dispositivo no soporta seguimiento facial")
            return
        }
        
        // Configurar ARSession
        let configuration = ARFaceTrackingConfiguration()
        arSession.run(configuration)
        
        // Generar gesto aleatorio
        currentGesture = FacialGesture.allCases.randomElement()
        
        // Iniciar temporizador
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timeRemaining = 30
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.authenticationFailed(reason: "Tiempo agotado")
            }
        }
    }
    
    @MainActor
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
    
    private func authenticationFailed(reason: String) {
        timer?.invalidate()
        Task { @MainActor in
            errorMessage = reason
            showingError = true
            
            // Guardar el fallo en el historial
            let history = AuthHistory(
                id: UUID(),
                siteId: site.id,
                siteName: "\(site.issuer) - \(site.name)",
                timestamp: Date(),
                success: false,
                failureReason: .timeout
            )
            
            try? await StorageService().saveHistory(history)
        }
    }
    
    private func gestureSucceeded() {
        timer?.invalidate()
        
        Task { @MainActor in
            // Guardar el historial de autenticación exitosa
            let history = AuthHistory(
                id: UUID(),
                siteId: site.id,
                siteName: "\(site.issuer) - \(site.name)",
                timestamp: Date(),
                success: true,
                failureReason: nil
            )
            
            try? await StorageService().saveHistory(history)
            
            // Notificar éxito
            NotificationCenter.default.post(name: .authenticationSucceeded, object: nil)
        }
    }
}

// MARK: - ARSessionDelegate
extension FaceAuthViewModel: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor else {
            return
        }
        
        // Verificar liveness primero
        /*guard livenessDetector.validateLiveness(with: faceAnchor) else {
            Task { @MainActor in
                authenticationFailed(reason: "Detección de vida fallida")
            }
            return
        }*/
        
        // Procesar el gesto facial actual
        if let currentGesture = currentGesture {
            processGesture(faceAnchor, expectedGesture: currentGesture)
        }
    }
    
    private func processGesture(_ faceAnchor: ARFaceAnchor, expectedGesture: FacialGesture) {
        let blendShapes = faceAnchor.blendShapes
        
        switch expectedGesture {
        case .smile:
            let smileLeft = blendShapes[.mouthSmileLeft]?.floatValue ?? 0
            let smileRight = blendShapes[.mouthSmileRight]?.floatValue ?? 0
            if (smileLeft + smileRight) / 2 > 0.5 {
                gestureSucceeded()
            }
            
        case .openMouth:
            if blendShapes[.jawOpen]?.floatValue ?? 0 > 0.5 {
                gestureSucceeded()
            }
            
        case .rightEyeWink:
            let rightBlink = blendShapes[.eyeBlinkRight]?.floatValue ?? 0
            let leftBlink = blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
            if rightBlink > 0.6 && leftBlink < 0.3 {
                gestureSucceeded()
            }
            
        case .leftEyeWink:
            let rightBlink = blendShapes[.eyeBlinkRight]?.floatValue ?? 0
            let leftBlink = blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
            if leftBlink > 0.6 && rightBlink < 0.3 {
                gestureSucceeded()
            }
            
        case .kissing:
            if blendShapes[.mouthPucker]?.floatValue ?? 0 > 0.5 {
                gestureSucceeded()
            }
        }
    }
}

extension Notification.Name {
    static let authenticationSucceeded = Notification.Name("authenticationSucceeded")
}
