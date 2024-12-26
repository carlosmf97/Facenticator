import SwiftUI

struct SiteListView: View {
    @StateObject private var viewModel = SiteListViewModel()
    @State private var showingAddSite = false
    @State private var showingFaceAuth: AuthSite?
    
    var body: some View {
        NavigationView{
            List {
                ForEach(viewModel.sites) { site in
                    Button {
                        showingFaceAuth = site
                    } label: {
                        SiteCell(site: site)
                    }
                }
                .listRowBackground(Color.clear)
            }
            .refreshable {
                await viewModel.loadSites()
            }
            .overlay {
                if viewModel.sites.isEmpty {
                    ContentUnavailableView(
                        "No hay sitios",
                        systemImage: "key.fill",
                        description: Text("Añadir sitio pulsando +")
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Sitios")
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddSite = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSite) {
                AddSiteView()
            }
            .fullScreenCover(item: $showingFaceAuth) { site in
                FaceAuthView(site: site)
            }
            .onAppear {
                Task {
                    await viewModel.loadSites()
                }
            }
        }
    }
    
}

