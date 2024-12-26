import Foundation

public enum StorageError: LocalizedError {
    case saveFailed
    case loadFailed
    case deleteFailed
    case syncFailed
    case encryptionFailed
    case invalidData
    case cloudKitError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "No se pudo guardar la información"
        case .loadFailed:
            return "No se pudo cargar la información"
        case .deleteFailed:
            return "No se pudo eliminar la información"
        case .syncFailed:
            return "Error de sincronización con iCloud"
        case .encryptionFailed:
            return "Error al encriptar los datos"
        case .invalidData:
            return "Los datos no son válidos"
        case .cloudKitError(let error):
            return "Error de iCloud: \(error.localizedDescription)"
        }
    }
}
