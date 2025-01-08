import ARKit
import Combine

class FaceRegistrationManager: NSObject, ObservableObject {
    static let shared = FaceRegistrationManager()
    
    @Published var isVerificationMode = false
    @Published var registrationProgress: Float = 0
    @Published var registrationStatus = ""
    @Published var currentGesture: FacialGesture?
    @Published var isRegistered = false
    
    let arSession = ARSession()
    private var faceAnchor: ARFaceAnchor?
    private var registeredFaceGeometry: ARFaceGeometry?
    private var currentGestureIndex = 0
    private var verificationGesture: FacialGesture?
    
    private override init() {
        super.init()
        isRegistered = UserDefaults.standard.bool(forKey: "FaceRegistrationCompleted")
        arSession.delegate = self
    }
    
    public func stopTracking() {
        // Solo permitimos detener si hemos completado la verificación
        if !isVerificationMode || registrationProgress >= 1.0 {
            arSession.pause()
            faceAnchor = nil
            currentGesture = nil
        }
    }
    
    public func startRegistration() {
        DispatchQueue.main.async {
            // Si ya está registrado, iniciamos verificación en su lugar
            if self.isRegistered {
                self.startVerification()
                return
            }
            
            self.isVerificationMode = false
            self.registrationProgress = 0
            self.currentGestureIndex = 0
            self.currentGesture = FacialGesture.registrationGestures[self.currentGestureIndex]
            self.registrationStatus = "Registra tus gestos faciales"
            
            let configuration = ARFaceTrackingConfiguration()
            self.arSession.run(configuration)
        }
    }
    
    public func startVerification() {
        DispatchQueue.main.async {
            self.isVerificationMode = true
            self.registrationProgress = 0
            
            // Seleccionar un gesto aleatorio para verificación
            self.verificationGesture = FacialGesture.registrationGestures.randomElement()
            self.currentGesture = self.verificationGesture
            self.registrationStatus = "Realiza el gesto solicitado"
            
            let configuration = ARFaceTrackingConfiguration()
            self.arSession.run(configuration)
        }
    }
    
    private func validateFaceGeometry(_ geometry: ARFaceGeometry) -> Bool {
        guard let registeredGeometry = registeredFaceGeometry else {
            // Si no hay geometría registrada, la guardamos
            registeredFaceGeometry = geometry
            return true
        }
        
        // Comparar la geometría actual con la registrada
        // Esto es una simplificación - en producción necesitarías un algoritmo más robusto
        let vertices = geometry.vertices
        let registeredVertices = registeredGeometry.vertices
        var totalDistance: Float = 0
        
        for i in 0..<vertices.count {
            let distance = simd_distance(vertices[i], registeredVertices[i])
            totalDistance += distance
        }
        
        let averageDistance = totalDistance / Float(vertices.count)
        return averageDistance < 0.1 // Umbral de similitud
    }
    
    private func detectGesture(_ anchor: ARFaceAnchor) -> FacialGesture? {
        let blendShapes = anchor.blendShapes
        
        // Guiño izquierdo: más preciso
        if let eyeBlinkLeft = blendShapes[.eyeBlinkLeft]?.floatValue,
           let eyeBlinkRight = blendShapes[.eyeBlinkRight]?.floatValue,
           eyeBlinkLeft > 0.85 && eyeBlinkRight < 0.15 {
            print("Guiño izquierdo detectado: L=\(eyeBlinkLeft) R=\(eyeBlinkRight)")
            return .leftEyeWink
        }
        
        // Guiño derecho: más preciso
        if let eyeBlinkRight = blendShapes[.eyeBlinkRight]?.floatValue,
           let eyeBlinkLeft = blendShapes[.eyeBlinkLeft]?.floatValue,
           eyeBlinkRight > 0.85 && eyeBlinkLeft < 0.15 {
            print("Guiño derecho detectado: R=\(eyeBlinkRight) L=\(eyeBlinkLeft)")
            return .rightEyeWink
        }
        
        // Imprimir valores para debug
        print("Blend Shapes valores:")
        print("Smile R: \(blendShapes[.mouthSmileRight]?.floatValue ?? 0)")
        print("Smile L: \(blendShapes[.mouthSmileLeft]?.floatValue ?? 0)")
        print("Brow Up: \(blendShapes[.browOuterUpRight]?.floatValue ?? 0)")
        print("Jaw Open: \(blendShapes[.jawOpen]?.floatValue ?? 0)")
        print("Eye Blink L: \(blendShapes[.eyeBlinkLeft]?.floatValue ?? 0)")
        print("Eye Blink R: \(blendShapes[.eyeBlinkRight]?.floatValue ?? 0)")
        
        // Sonrisa: combinar ambos lados y reducir umbral
        if let smileRight = blendShapes[.mouthSmileRight]?.floatValue,
           let smileLeft = blendShapes[.mouthSmileLeft]?.floatValue,
           (smileRight + smileLeft) / 2 > 0.3 {
            print("Sonrisa detectada!")
            return .smile
        }
        
        // Cejas
        if let browRight = blendShapes[.browOuterUpRight]?.floatValue,
           let browLeft = blendShapes[.browOuterUpLeft]?.floatValue,
           (browRight + browLeft) / 2 > 0.3 {
            print("Cejas detectadas!")
            return .eyebrows
        }
        
        // Boca abierta
        if let jawOpen = blendShapes[.jawOpen]?.floatValue,
           jawOpen > 0.4 {
            print("Boca abierta detectada!")
            return .openMouth
        }
        
        return nil
    }
    
    func resetVerification() {
        DispatchQueue.main.async {
            self.registrationProgress = 0
            self.currentGestureIndex = 0
            self.currentGesture = FacialGesture.registrationGestures[self.currentGestureIndex]
            self.registrationStatus = "Realiza el gesto solicitado"
        }
    }
}

// MARK: - ARSessionDelegate
extension FaceRegistrationManager: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor else { 
            print("No se encontró face anchor")
            return 
        }
        
        self.faceAnchor = faceAnchor
        
        // Validar que es la misma cara
        guard validateFaceGeometry(faceAnchor.geometry) else {
            print("Geometría facial no válida")
            registrationStatus = "Cara no reconocida"
            return
        }
        
        // Detectar gesto actual
        if let detectedGesture = detectGesture(faceAnchor) {
            print("Gesto detectado: \(detectedGesture)")
            if isVerificationMode {
                handleVerificationGesture(detectedGesture)
            } else {
                handleRegistrationGesture(detectedGesture)
            }
        } else {
            print("Ningún gesto detectado")
        }
    }
    
    private func handleRegistrationGesture(_ gesture: FacialGesture) {
        // Primero verificamos que no nos pasemos del array
        guard currentGestureIndex < FacialGesture.registrationGestures.count else {
            print("Registro completado - índice fuera de rango")
            completeRegistration()
            return
        }
        
        // Verificamos que el gesto coincida con el esperado
        guard gesture == FacialGesture.registrationGestures[currentGestureIndex] else {
            print("Gesto incorrecto: esperado \(FacialGesture.registrationGestures[currentGestureIndex]), recibido \(gesture)")
            // No cambiamos el progress cuando hay un error
            return
        }
        
        print("Gesto registrado correctamente: \(gesture)")
        
        DispatchQueue.main.async {
            // Actualizamos el progreso antes de incrementar el índice
            self.registrationProgress = Float(self.currentGestureIndex + 1) / Float(FacialGesture.registrationGestures.count)
            
            // Avanzamos al siguiente gesto
            self.currentGestureIndex += 1
            
            if self.currentGestureIndex < FacialGesture.registrationGestures.count {
                // Todavía hay más gestos por registrar
                self.currentGesture = FacialGesture.registrationGestures[self.currentGestureIndex]
                self.registrationStatus = "¡Correcto! Siguiente gesto: \(self.currentGesture?.description ?? "")"
                print("Siguiente gesto: \(String(describing: self.currentGesture))")
            } else {
                // Hemos completado todos los gestos
                print("Registro completado")
                self.registrationStatus = "¡Registro completado!"
                self.completeRegistration()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.stopTracking()
                }
            }
        }
    }
    
    private func handleVerificationGesture(_ gesture: FacialGesture) {
        guard gesture == verificationGesture else { return }
        
        // Verificación exitosa
        registrationProgress = 1.0
        registrationStatus = "¡Verificación exitosa!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.stopTracking()
        }
    }
    
    private func completeRegistration() {
        DispatchQueue.main.async {
            self.isRegistered = true
            UserDefaults.standard.set(true, forKey: "FaceRegistrationCompleted")
            
            // Guardar el historial de registro exitoso
            let context = PersistenceController.shared.container.viewContext
            let historyItem = HistoryItem(context: context)
            historyItem.id = UUID()
            historyItem.timestamp = Date()
            historyItem.success = true
            historyItem.failureReason = "" // Añadimos un valor por defecto
            historyItem.siteId = UUID() // ID temporal para el registro
            historyItem.siteIssuer = "Sistema"
            historyItem.siteName = "Registro Facial"
            
            do {
                try context.save()
            } catch {
                print("Error guardando historial: \(error)")
            }
        }
    }
} 

