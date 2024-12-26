import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            SiteListView()
                .navigationTitle("Sitios")
                .tabItem {
                    Label("Sitios", systemImage: "list.bullet")
                }
                .tag(0)
            
            HistoryView()
                .navigationTitle("Historial")
                .tabItem {
                    Label("Historial", systemImage: "clock")
                }
                .tag(1)
            
           
            SettingsView()
                .navigationTitle("Ajustes")
                .tabItem {
                    Label("Ajustes", systemImage: "gear")
                }
                .tag(2)
        }
        .accentColor(colorScheme == .dark ? .white : .blue)
        .onAppear {
            // Configurar la apariencia de la TabBar
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = appearance
            
            // Configurar la apariencia de la NavigationBar
            let navigationAppearance = UINavigationBarAppearance()
            navigationAppearance.configureWithDefaultBackground()
            UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance
        }
    }
}

struct SettingsView: View {
    @AppStorage("useBiometrics") private var useBiometrics = true
    @AppStorage("requireLivenessCheck") private var requireLivenessCheck = true
    
    var body: some View {
        List {
            Section(header: Text("Seguridad")) {
                Toggle("Usar Face ID", isOn: $useBiometrics)
                Toggle("Requerir prueba de vida", isOn: $requireLivenessCheck)
            }
            
            Section(header: Text("Acerca de")) {
                HStack {
                    Text("Versión")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
