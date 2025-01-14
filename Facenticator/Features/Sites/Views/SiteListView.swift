import SwiftUI
import LocalAuthentication

struct SiteListView: View {
    @StateObject private var viewModel = SiteListViewModel()
    @StateObject private var biometricManager = BiometricManager.shared
    @StateObject private var faceManager = FaceRegistrationManager.shared
    @State private var showingVerificationIntro = false
    @State private var showingAuthRequest = false
    @State private var searchText = ""
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
                    handleAuthenticationRequest()
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
                            handleAuthenticationRequest()
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
        .sheet(isPresented: $showingVerificationIntro) {
            if let site = selectedSite {
                VerificationIntroView(
                    site: site,
                    showVerification: $showingVerificationIntro,
                    showAuthRequest: $showingAuthRequest
                )
            }
        }
        .sheet(isPresented: $showingAuthRequest) {
            if let site = selectedSite {
                AuthRequestView(site: site, isPresented: $showingAuthRequest)
            }
        }
    }
    
    private func handleAuthenticationRequest() {
        // Buscar un sitio para la prueba
        guard let site = viewModel.filteredSites.first(where: { $0.authLevel == AuthorizationLevel.biometric.rawValue }) ?? viewModel.filteredSites.first else {
            print("No hay sitios disponibles")
            return
        }
        
        selectedSite = site
        
        if !faceManager.isRegistered {
            // Si no hay cara registrada, mostrar registro directamente
            showingAuthRequest = true
        } else if biometricManager.skipVerificationIntro {
            // Si hay cara y queremos saltar intro, mostrar auth directamente
            showingAuthRequest = true
        } else {
            // Si hay cara pero queremos mostrar intro
            showingVerificationIntro = true
        }
        
        // Enviar notificación
        sendTestNotification(for: site)
    }
    
    private func sendTestNotification(for site: Site) {
        let content = UNMutableNotificationContent()
        content.title = "Verificación Biométrica Requerida"
        content.body = "Se requiere tu verificación facial para \(site.wrappedIssuer)"
        content.sound = .default
        content.userInfo = [
            "siteId": site.id?.uuidString ?? UUID().uuidString,
            "requestId": "test-\(Int.random(in: 1000...9999))"
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        HapticManager.shared.impact(style: .medium)
    }
}


