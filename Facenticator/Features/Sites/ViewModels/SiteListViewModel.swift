import CoreData
import Combine

class SiteListViewModel: ObservableObject {
    @Published var sites: [Site] = []
    @Published var searchText = ""
    @Published var isLoading = false
    
    private var context: NSManagedObjectContext
    
    var filteredSites: [Site] {
        if searchText.isEmpty {
            return sites
        }
        return sites.filter { site in
            site.wrappedName.localizedCaseInsensitiveContains(searchText) ||
            site.wrappedIssuer.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        loadSites()
        if sites.isEmpty {
            createDummySites()
        }
    }
    
    func loadSites() {
        let request = NSFetchRequest<Site>(entityName: "Site")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Site.lastUsed, ascending: false)]
        
        do {
            sites = try context.fetch(request)
        } catch {
            print("Error cargando sitios: \(error)")
        }
    }
    
    private func createDummySites() {
        for dummySite in DummyData.sites {
            let site = Site(context: context)
            site.id = UUID()
            site.name = dummySite.name
            site.issuer = dummySite.issuer
            site.logoUrl = dummySite.logoUrl
            site.authLevel = dummySite.authLevel.rawValue
            site.secret = "JBSWY3DPEHPK3PXP" // Secreto de ejemplo
            site.createdAt = Date()
            site.lastUsed = Date()
        }
        
        do {
            try context.save()
            loadSites()
        } catch {
            print("Error creando sitios dummy: \(error)")
        }
    }
    
    func addSite(name: String, issuer: String, secret: String) {
        let site = Site(context: context)
        site.id = UUID()
        site.name = name
        site.issuer = issuer
        site.secret = EncryptionService.shared.encrypt(secret)
        site.createdAt = Date()
        site.lastUsed = Date()
        
        do {
            try context.save()
            loadSites()
        } catch {
            print("Error guardando sitio: \(error)")
        }
    }
    
    func deleteSite(at indexSet: IndexSet) {
        indexSet.forEach { index in
            let site = sites[index]
            context.delete(site)
        }
        
        do {
            try context.save()
            loadSites()
        } catch {
            print("Error eliminando sitio: \(error)")
        }
    }
    
    func updateLastUsed(for site: Site) {
        site.lastUsed = Date()
        
        do {
            try context.save()
        } catch {
            print("Error actualizando último uso: \(error)")
        }
    }
} 
