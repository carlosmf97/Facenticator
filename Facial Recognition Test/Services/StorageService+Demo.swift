import Foundation

extension StorageService {
    func loadDemoData() async throws {
        // Sitios de ejemplo
        let demoSites: [AuthSite] = [
            AuthSite(
                id: "1",
                name: "Cuenta Personal",
                issuer: "Google",
                secret: "1234-5678-9012-3456",
                createdAt: Date().addingTimeInterval(-86400 * 7), // 7 días atrás
                lastUsed: Date().addingTimeInterval(-3600) // 1 hora atrás
            ),
            AuthSite(
                id: "2",
                name: "Cuenta de Trabajo",
                issuer: "Microsoft",
                secret: "2345-6789-0123-4567",
                createdAt: Date().addingTimeInterval(-86400 * 14), // 14 días atrás
                lastUsed: Date().addingTimeInterval(-7200) // 2 horas atrás
            ),
            AuthSite(
                id: "3",
                name: "Banco Principal",
                issuer: "BBVA",
                secret: "3456-7890-1234-5678",
                createdAt: Date().addingTimeInterval(-86400 * 3), // 3 días atrás
                lastUsed: Date()
            )
        ]
        
        // Historial de ejemplo
        let demoHistory: [AuthHistory] = [
            AuthHistory(
                id: UUID(),
                siteId: "1",
                siteName: "Google - Cuenta Personal",
                timestamp: Date().addingTimeInterval(-3600),
                success: true,
                failureReason: nil
            ),
            AuthHistory(
                id: UUID(),
                siteId: "2",
                siteName: "Microsoft - Cuenta de Trabajo",
                timestamp: Date().addingTimeInterval(-7200),
                success: false,
                failureReason: .wrongGesture
            ),
            AuthHistory(
                id: UUID(),
                siteId: "3",
                siteName: "BBVA - Banco Principal",
                timestamp: Date(),
                success: true,
                failureReason: nil
            ),
            AuthHistory(
                id: UUID(),
                siteId: "1",
                siteName: "Google - Cuenta Personal",
                timestamp: Date().addingTimeInterval(-86400),
                success: false,
                failureReason: .timeout
            ),
            AuthHistory(
                id: UUID(),
                siteId: "2",
                siteName: "Microsoft - Cuenta de Trabajo",
                timestamp: Date().addingTimeInterval(-86400 * 2),
                success: true,
                failureReason: nil
            )
        ]
        
        // Guardar datos de ejemplo
        for site in demoSites {
            try await saveSite(site)
        }
        
        for entry in demoHistory {
            try await saveHistory(entry)
        }
    }
} 