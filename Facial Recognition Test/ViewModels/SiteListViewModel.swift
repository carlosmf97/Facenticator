import SwiftUI

class SiteListViewModel: ObservableObject {
    @Published var sites: [AuthSite] = []
    @Published var showingError = false
    @Published var errorMessage = ""
    
    private let storageService = StorageService()
    private let biometricService = BiometricService()
    
    init() {
        Task {
            await loadSites()
        }
    }
    
    @MainActor
    public func loadSites() async {
        do {
            sites = try await storageService.loadSites()
        } catch {
            errorMessage = "Error al cargar los sitios"
            showingError = true
        }
    }
    
    @MainActor
    func authenticate(site: AuthSite) async {
        do {
            // Verificar Face ID primero
            try await biometricService.authenticateUser()
            
            // Iniciar flujo de autenticación con gestos
            let authenticationView = FaceAuthView(site: site)
            // Presentar vista de autenticación
            // (Implementaremos la lógica de presentación más adelante)
            
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}
