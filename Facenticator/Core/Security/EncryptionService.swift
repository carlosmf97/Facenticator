import Foundation
import CryptoKit

class EncryptionService {
    static let shared = EncryptionService()
    
    private let keychain = KeychainManager.shared
    private let keychainKey = "encryption_key"
    
    private var key: SymmetricKey? {
        get {
            guard let data = try? keychain.loadData(identifier: keychainKey) else {
                return generateNewKey()
            }
            return SymmetricKey(data: data)
        }
    }
    
    private func generateNewKey() -> SymmetricKey {
        let key = SymmetricKey(size: .bits256)
        try? keychain.storeData(key.withUnsafeBytes { Data($0) }, identifier: keychainKey)
        return key
    }
    
    func encrypt(_ string: String) -> String? {
        guard let data = string.data(using: .utf8),
              let key = key else { return nil }
        
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined?.base64EncodedString()
        } catch {
            print("Error encriptando: \(error)")
            return nil
        }
    }
    
    func decrypt(_ string: String) -> String? {
        guard let data = Data(base64Encoded: string),
              let key = key else { return nil }
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            print("Error desencriptando: \(error)")
            return nil
        }
    }
} 