import Foundation

extension HistoryItem {
    var wrappedSiteIssuer: String {
        siteIssuer ?? "Desconocido"
    }
    
    var wrappedSiteName: String {
        siteName ?? "Desconocido"
    }
    
    var wrappedTimestamp: Date {
        timestamp ?? Date()
    }
} 