import Foundation

class AddSiteViewModel: ObservableObject {
    @Published var showingError = false
    @Published var errorMessage = ""
    @Published var siteName = ""
    @Published var siteCode = ""
    
    let storageService = StorageService()
    
    func saveSite(_ site: AuthSite) async throws {
        try await storageService.saveSite(site)
    }
    
    func processQRCode(_ code: String) async {
        do {
            guard let url = URL(string: code),
                  url.scheme == "otpauth",
                  url.host == "totp" else {
                throw ValidationError.invalidFormat
            }
            
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let queryItems = components?.queryItems ?? []
            
            guard let secret = queryItems.first(where: { $0.name == "secret" })?.value,
                  let issuer = queryItems.first(where: { $0.name == "issuer" })?.value else {
                throw ValidationError.missingRequiredFields
            }
            
            // El label puede estar en el path o en los query params
            var name = url.lastPathComponent
            if name.contains(":") {
                name = name.components(separatedBy: ":")[1]
            }
            
            let site = AuthSite(
                id: UUID().uuidString,
                name: name,
                issuer: issuer,
                secret: secret,
                createdAt: Date(),
                lastUsed: nil
            )
            
            try await storageService.saveSite(site)
            await MainActor.run {
                // Notificar éxito y cerrar vista
                NotificationCenter.default.post(name: .siteAdded, object: nil)
            }
        } catch {
            await showError(error.localizedDescription)
        }
    }
    
    @MainActor
    func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
    
    enum ValidationError: LocalizedError {
        case invalidFormat
        case missingRequiredFields
        
        var errorDescription: String? {
            switch self {
            case .invalidFormat:
                return "El código QR no tiene el formato correcto"
            case .missingRequiredFields:
                return "Faltan campos requeridos en el código QR"
            }
        }
    }
}

extension Notification.Name {
    static let siteAdded = Notification.Name("siteAdded")
}
