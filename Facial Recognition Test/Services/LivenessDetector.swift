import Foundation
import ARKit

class LivenessDetector {
    enum LivenessState: Equatable {
        case notStarted
        case inProgress(progress: Double)
        case completed
        case failed(reason: String)
    }
    
    private var lastGestureTime: Date?
    private var gestureSequence: [FacialGesture] = []
    private var currentState: LivenessState = .notStarted
    private var consecutiveFailures = 0
    private let maxFailures = 3
    
    func validateLiveness(with anchor: ARFaceAnchor) -> Bool {
        // Verificar si hay demasiados fallos consecutivos
        if consecutiveFailures >= maxFailures {
            currentState = .failed(reason: "Demasiados intentos fallidos")
            return false
        }
        
        let now = Date()
        
        // Reiniciar si ha pasado demasiado tiempo
        if let lastTime = lastGestureTime,
           now.timeIntervalSince(lastTime) > 5 {
            gestureSequence.removeAll()
            currentState = .notStarted
        }
        
        lastGestureTime = now
        
        // Verificar parpadeo natural
        let leftEyeBlink = anchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
        let rightEyeBlink = anchor.blendShapes[.eyeBlinkRight]?.floatValue ?? 0
        let naturalBlinking = (leftEyeBlink + rightEyeBlink) / 2 > 0.5
        
        // Verificar movimiento de cabeza
        let headRotation = anchor.transform.columns.2
        let lookingForward = abs(headRotation.z) > 0.95 // Mirando aproximadamente hacia adelante
        
        // Verificar expresiones faciales
        let smileLeft = anchor.blendShapes[.mouthSmileLeft]?.floatValue ?? 0
        let smileRight = anchor.blendShapes[.mouthSmileRight]?.floatValue ?? 0
        let naturalExpression = (smileLeft + smileRight) / 2 < 0.8 // No sonriendo excesivamente
        
        let isLive = naturalBlinking && lookingForward && naturalExpression
        
        if isLive {
            consecutiveFailures = 0
            currentState = .completed
        } else {
            consecutiveFailures += 1
            currentState = .failed(reason: "Movimiento no natural detectado")
        }
        
        return isLive
    }
    
    func getCurrentState() -> LivenessState {
        return currentState
    }
    
    func reset() {
        currentState = .notStarted
        consecutiveFailures = 0
        gestureSequence.removeAll()
        lastGestureTime = nil
    }
}
