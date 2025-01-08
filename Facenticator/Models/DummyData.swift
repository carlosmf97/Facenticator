import Foundation
import CoreData

struct DummySite {
    let name: String
    let issuer: String
    let logoUrl: String
    let authLevel: AuthorizationLevel
}

struct DummyData {
    static let sites: [DummySite] = [
        DummySite(
            name: "carlos@gmail.com",
            issuer: "Google",
            logoUrl: "https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png",
            authLevel: .simple
        ),
        DummySite(
            name: "carlos123",
            issuer: "BBVA",
            logoUrl: "https://logos-world.net/wp-content/uploads/2021/02/BBVA-Logo-700x394.png",
            authLevel: .biometric
        ),
        DummySite(
            name: "carlos.dev",
            issuer: "GitHub",
            logoUrl: "https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png",
            authLevel: .simple
        ),
        DummySite(
            name: "carlos.business",
            issuer: "Amazon AWS",
            logoUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Amazon_Web_Services_Logo.svg/2560px-Amazon_Web_Services_Logo.svg.png",
            authLevel: .simple
        ),
        DummySite(
            name: "carlos.dropbox",
            issuer: "Dropbox",
            logoUrl: "https://aem.dropbox.com/cms/content/dam/dropbox/www/en-us/branding/dropbox-logo@2x.jpg",
            authLevel: .biometric
        ),
        DummySite(
            name: "carlos.slack",
            issuer: "Slack",
            logoUrl: "https://a.slack-edge.com/80588/marketing/img/icons/icon_slack_hash_colored.png",
            authLevel: .simple
        ),
        DummySite(
            name: "carlos.spotify",
            issuer: "Spotify",
            logoUrl: "https://storage.googleapis.com/pr-newsroom-wp/1/2018/11/Spotify_Logo_RGB_Green.png",
            authLevel: .biometric
        )
    ]
    
    static let historyReasons: [String] = [
        "Gesto facial no reconocido",
        "Tiempo de respuesta excedido",
        "Intento desde ubicación no reconocida",
        "Patrón de uso sospechoso",
        "Múltiples intentos fallidos"
    ]
    
    static func createDummyHistory(context: NSManagedObjectContext) {
        print("Iniciando creación de historial dummy...")
        
        // Primero, eliminar todo el historial existente
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = HistoryItem.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? context.execute(deleteRequest)
        
        // Crear 20 entradas de historial variadas
        for i in 0..<20 {
            let item = HistoryItem(context: context)
            item.id = UUID()
            
            // Seleccionar un sitio aleatorio de los sitios dummy
            let randomSite = sites.randomElement()!
            
            // Configurar datos del sitio
            item.siteName = randomSite.name
            item.siteIssuer = randomSite.issuer
            item.siteId = UUID() // ID temporal
            
            // Fecha aleatoria en los últimos 7 días, ordenadas de más reciente a más antigua
            let daysAgo = Double(i) / 2.0 // Esto distribuirá los eventos en los últimos 10 días
            item.timestamp = Date().addingTimeInterval(-daysAgo * 24 * 60 * 60)
            
            // 70% de probabilidad de éxito
            item.success = Double.random(in: 0...1) <= 0.7
            
            if !item.success {
                item.failureReason = historyReasons.randomElement()
            } else {
                item.failureReason = nil
            }
            
            print("Creado item \(i + 1): \(item.siteName ?? "") - \(item.success ? "Éxito" : "Fallo")")
        }
        
        do {
            try context.save()
            print("Datos dummy guardados correctamente")
        } catch {
            print("Error guardando datos dummy: \(error)")
        }
    }
} 
