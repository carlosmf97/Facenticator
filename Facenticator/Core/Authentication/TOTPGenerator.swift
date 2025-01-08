import Foundation
import CryptoKit

class TOTPGenerator {
    static let shared = TOTPGenerator()
    
    private let period: TimeInterval = 30
    private let digits: Int = 6
    private var codeCache: [String: String] = [:] // Cache para los códigos
    
    func generateCode(for secret: String) -> String? {
        // Por ahora devolvemos un código de ejemplo
        // Cuando implementemos la generación real, usaremos el cache
        return "123456"
    }
    
    func timeRemaining() -> Int {
        let timeInterval = Date().timeIntervalSince1970
        return Int(period - timeInterval.truncatingRemainder(dividingBy: period))
    }
    
    func clearCache() {
        codeCache.removeAll()
    }
} 
