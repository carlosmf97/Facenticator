import Foundation

extension Site {
    var wrappedName: String {
        name ?? "Desconocido"
    }
    
    var wrappedIssuer: String {
        issuer ?? "Desconocido"
    }
    
    var wrappedSecret: String {
        secret ?? ""
    }
} 