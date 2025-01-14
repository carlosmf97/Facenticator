import ARKit
import Combine

class FaceRegistrationManager: NSObject, ObservableObject {
    static let shared = FaceRegistrationManager()
    
    @Published var isVerificationMode = false
    @Published var registrationProgress: Float = 0
    @Published var registrationStatus = ""
    @Published var currentGesture: FacialGesture?
    @Published var isRegistered = false
    
    private var registeredFaceHash: Data? {
        get {
            guard let data = UserDefaults.standard.data(forKey: "RegisteredFaceHash") else {
                return nil
            }
            return data
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "RegisteredFaceHash")
        }
    }
    
    let arSession = ARSession()
    private var faceAnchor: ARFaceAnchor?
    private var currentGestureIndex = 0
    private var verificationGesture: FacialGesture?
    
    private var registrationHashes: [Data] = [] // Array para guardar los hashes de cada gesto
    
    private override init() {
        super.init()
        isRegistered = UserDefaults.standard.bool(forKey: "FaceRegistrationCompleted")
        arSession.delegate = self
    }
    
    public func startRegistration() {
        DispatchQueue.main.async {
            print("Iniciando registro...")
            self.printRegistrationStatus() // Debug inicial
            
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
            print("Iniciando verificación...")
            self.printRegistrationStatus() // Debug de verificación
            
            guard self.registeredFaceHash != nil else {
                print("Error: Intento de verificación sin registro previo")
                self.registrationStatus = "Error: No hay cara registrada"
                return
            }
            
            self.isVerificationMode = true
            self.registrationProgress = 0
            self.verificationGesture = FacialGesture.registrationGestures.randomElement()
            self.currentGesture = self.verificationGesture
            self.registrationStatus = "Realiza el gesto: \(self.verificationGesture?.description ?? "")"
            
            let configuration = ARFaceTrackingConfiguration()
            self.arSession.run(configuration)
        }
    }
    
    private func validateFaceGeometry(_ geometry: ARFaceGeometry) -> Bool {
        let vertices = geometry.vertices
        let currentHash = calculateFaceHash(vertices)
        
        // Si estamos en modo verificación
        if isVerificationMode {
            guard let savedHash = registeredFaceHash else {
                print("No hay hash facial guardado")
                return false
            }
            
            // Primero verificamos si es la misma persona
            let similarity = compareFaceHashes(currentHash, savedHash)
            print("Verificación - Similitud facial: \(similarity * 100)%")
            
            if similarity < 0.80 {
                print("Cara no reconocida")
                registrationStatus = "Cara no reconocida"
                return false
            }
            
            // Si es la misma persona, verificamos el gesto
            if let detectedGesture = detectGesture(faceAnchor!) {
                if detectedGesture == verificationGesture {
                    print("Gesto correcto y cara verificada")
                    return true
                } else {
                    print("Esperando gesto correcto...")
                    return false
                }
            }
            
            return false
        }
        
        // Si estamos registrando, guardamos el hash de cada gesto
        if currentGestureIndex < FacialGesture.registrationGestures.count {
            registrationHashes.append(currentHash)
            print("Hash guardado para gesto \(currentGestureIndex + 1)")
            
            // Al completar todos los gestos, combinamos los hashes
            if currentGestureIndex == FacialGesture.registrationGestures.count - 1 {
                let finalHash = combineHashes(registrationHashes)
                registeredFaceHash = finalHash
                UserDefaults.standard.set(finalHash, forKey: "RegisteredFaceHash")
                UserDefaults.standard.synchronize()
                print("Hash final combinado y guardado")
                registrationHashes.removeAll()
            }
        }
        
        return true
    }
    
    private func calculateFaceHash(_ vertices: UnsafePointer<vector_float3>) -> Data {
        var hashableData = Data()
        let vertexCount = 1220 // Usamos todos los vértices
        
        // Calcular el centro de la cara para normalización
        var center = vector_float3(0, 0, 0)
        for i in 0..<vertexCount {
            center += vertices[i]
        }
        center = center / Float(vertexCount)
        
        // Normalizar y guardar todos los vértices
        for i in 0..<vertexCount {
            let normalizedVertex = vertices[i] - center
            hashableData.append(contentsOf: withUnsafeBytes(of: normalizedVertex) { Data($0) })
        }
        
        return EncryptionService.shared.hash(data: hashableData)
    }
    
    private func combineHashes(_ hashes: [Data]) -> Data {
        var combinedData = Data()
        for hash in hashes {
            combinedData.append(hash)
        }
        return EncryptionService.shared.hash(data: combinedData)
    }
    
    private func compareFaceHashes(_ hash1: Data, _ hash2: Data) -> Double {
        let matching = zip(hash1, hash2).filter { $0 == $1 }.count
        let total = hash1.count
        return Double(matching) / Double(total)
    }
    
    private func detectGesture(_ anchor: ARFaceAnchor) -> FacialGesture? {
        let blendShapes = anchor.blendShapes
        
        // Guiño derecho: más preciso (corregido)
        if let eyeBlinkRight = blendShapes[.eyeBlinkRight]?.floatValue,
           let eyeBlinkLeft = blendShapes[.eyeBlinkLeft]?.floatValue,
           eyeBlinkRight > 0.85 && eyeBlinkLeft < 0.15 {
            print("Guiño derecho detectado: R=\(eyeBlinkRight) L=\(eyeBlinkLeft)")
            return .rightEyeWink
        }
        
        // Guiño izquierdo: más preciso (corregido)
        if let eyeBlinkLeft = blendShapes[.eyeBlinkLeft]?.floatValue,
           let eyeBlinkRight = blendShapes[.eyeBlinkRight]?.floatValue,
           eyeBlinkLeft > 0.85 && eyeBlinkRight < 0.15 {
            print("Guiño izquierdo detectado: L=\(eyeBlinkLeft) R=\(eyeBlinkRight)")
            return .leftEyeWink
        }
        

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
    
    public func stopTracking() {
        DispatchQueue.main.async {
            self.arSession.pause()
            self.faceAnchor = nil 
            self.currentGesture = nil
            self.registrationStatus = ""
        }
    }
    
    private func completeRegistration() {
        DispatchQueue.main.async {
            print("Completando registro...")
            
            guard let faceAnchor = self.faceAnchor else {
                print("Error: No hay face anchor al completar registro")
                return
            }
            
            let finalHash = self.calculateFaceHash(faceAnchor.geometry.vertices)
            self.registeredFaceHash = finalHash
            
            UserDefaults.standard.set(finalHash, forKey: "RegisteredFaceHash")
            UserDefaults.standard.set(true, forKey: "FaceRegistrationCompleted")
            UserDefaults.standard.synchronize()
            
            self.isRegistered = true
            
            print("Registro completado...")
            self.printRegistrationStatus() // Debug final
            
            // Guardar el historial
            let context = PersistenceController.shared.container.viewContext
            let historyItem = HistoryItem(context: context)
            historyItem.id = UUID()
            historyItem.timestamp = Date()
            historyItem.success = true
            historyItem.failureReason = ""
            historyItem.siteId = UUID()
            historyItem.siteIssuer = "Sistema"
            historyItem.siteName = "Registro Facial"
            
            do {
                try context.save()
                print("Historial guardado correctamente")
            } catch {
                print("Error guardando historial: \(error)")
            }
        }
    }
    
    // Añadir método para debug
    public func printRegistrationStatus() {
        let hash = UserDefaults.standard.data(forKey: "RegisteredFaceHash")
        let isReg = UserDefaults.standard.bool(forKey: "FaceRegistrationCompleted")
        print("Estado actual de registro:")
        print("Hash guardado: \(hash != nil)")
        print("isRegistered: \(isReg)")
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
            return
        }
        
        DispatchQueue.main.async {
            self.registrationProgress = Float(self.currentGestureIndex + 1) / Float(FacialGesture.registrationGestures.count)
            self.currentGestureIndex += 1
            
            if self.currentGestureIndex < FacialGesture.registrationGestures.count {
                self.currentGesture = FacialGesture.registrationGestures[self.currentGestureIndex]
                self.registrationStatus = "¡Correcto! Siguiente gesto: \(self.currentGesture?.description ?? "")"
            } else {
                self.completeRegistration()
                self.registrationStatus = "¡Registro completado!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.stopTracking()
                }
            }
        }
    }
    
    private func handleVerificationGesture(_ gesture: FacialGesture) {
        guard gesture == verificationGesture else { return }
        
        // Verificar que la cara coincide con el hash guardado
        guard let faceAnchor = self.faceAnchor,
              validateFaceGeometry(faceAnchor.geometry) else {
            self.registrationStatus = "Cara no reconocida"
            return
        }
        
        // Verificación exitosa
        self.registrationProgress = 1.0
        self.registrationStatus = "¡Verificación exitosa!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.stopTracking()
        }
    }
} 

