import Foundation

actor StorageService {
    // MARK: - Site Management
    public func loadSites() async throws -> [AuthSite] {
        // Primero intentar cargar desde local
        let localSites = try await loadLocalSites()
        
        // Si no hay datos, cargar datos de ejemplo
        if localSites.isEmpty {
            try await loadDemoData()
            return try await loadLocalSites().values.sorted { $0.name < $1.name }
        }
        
        return Array(localSites.values)
    }
    
    func saveSite(_ site: AuthSite) async throws {
        try await saveSiteLocally(site)
    }
    
    private func saveSiteLocally(_ site: AuthSite) async throws {
        var sites = try await loadLocalSites()
        sites[site.id] = site
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(sites)
        UserDefaults.standard.set(data, forKey: "auth_sites")
    }
    
    private func loadLocalSites() async throws -> [String: AuthSite] {
        guard let data = UserDefaults.standard.data(forKey: "auth_sites"),
              let sites = try? JSONDecoder().decode([String: AuthSite].self, from: data) else {
            return [:]
        }
        return sites
    }
    
    // MARK: - History Management
    func saveHistory(_ entry: AuthHistory) async throws {
        var history = try await loadHistory()
        history.append(entry)
        
        // Mantener solo los últimos 100 registros
        if history.count > 100 {
            history.removeFirst(history.count - 100)
        }
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(history)
        UserDefaults.standard.set(data, forKey: "auth_history")
    }
    
    func loadHistory() async throws -> [AuthHistory] {
        guard let data = UserDefaults.standard.data(forKey: "auth_history"),
              let history = try? JSONDecoder().decode([AuthHistory].self, from: data) else {
            return []
        }
        return history
    }
    
    // MARK: - Demo Data
}
