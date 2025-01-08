import SwiftUI
import LocalAuthentication

struct SiteListView: View {
    @StateObject private var viewModel = SiteListViewModel()
    @State private var showingAddSite = false
    @State private var searchText = ""
    @State private var showingBiometricAuth = false
    @State private var isAnimatingButton = false
    @State private var selectedSite: Site?
    @State private var authResult: Bool?
    
    var body: some View {
        VStack {
            // Barra de título personalizada
            HStack {
                Text("Sitios")
                    .font(AppTheme.Typography.title)
                    .padding(.leading)
                Spacer()
                Button {
                    showingAddSite = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                }
                .padding(.trailing)
            }
            .padding(.vertical)
            
            // Contenido principal
            ZStack {
                List {
                    ForEach(viewModel.filteredSites, id: \.id) { site in
                        SiteCell(site: site)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .onDelete { indexSet in
                        viewModel.deleteSite(at: indexSet)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    viewModel.loadSites()
                }
                .searchable(text: $searchText, prompt: "Buscar sitios")
                
                // Botón flotante de autenticación
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isAnimatingButton = true
                                sendTestNotification()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                isAnimatingButton = false
                            }
                        } label: {
                            Image(systemName: "faceid")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(AppTheme.Colors.primary)
                                .clipShape(Circle())
                                .shadow(color: AppTheme.Colors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .scaleEffect(isAnimatingButton ? 0.9 : 1)
                        .padding(.trailing, 20)
                        .padding(.bottom, 70)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddSite) {
            AddSiteView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingBiometricAuth) {
            BiometricAuthView(showBiometricAuth: $showingBiometricAuth, authResult: $authResult)
        }
    }
    
    private func sendTestNotification() {
        // Buscar un sitio con autenticación biométrica
        let biometricSites = viewModel.filteredSites.filter { site in
            site.authLevel == AuthorizationLevel.biometric.rawValue
        }
        
        guard let selectedSite = biometricSites.first ?? viewModel.filteredSites.first else {
            print("No hay sitios disponibles")
            return
        }
        
        // En lugar de establecer selectedSite, mostramos directamente BiometricAuthView
        showingBiometricAuth = true
        
        // Enviar notificación
        let content = UNMutableNotificationContent()
        content.title = "Verificación Biométrica Requerida"
        content.body = "Se requiere tu verificación facial para \(selectedSite.wrappedIssuer)"
        content.sound = .default
        content.userInfo = [
            "siteId": selectedSite.id?.uuidString ?? UUID().uuidString,
            "requestId": "test-\(Int.random(in: 1000...9999))"
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        HapticManager.shared.impact(style: .medium)
    }
}

