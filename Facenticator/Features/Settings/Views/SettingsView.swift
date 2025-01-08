import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    @AppStorage("biometricEnabled") private var biometricEnabled = false
    @AppStorage("skipVerificationIntro") private var skipVerificationIntro = false
    @State private var showingBiometricSetup = false
    @State private var showingDeleteConfirmation = false
    @State private var showingBackupInfo = false
    
    var body: some View {
        VStack {
            // Barra de título personalizada
            HStack {
                Text("Ajustes")
                    .font(AppTheme.Typography.title)
                    .padding(.leading)
                Spacer()
            }
            .padding(.vertical)
            
            // Contenido principal
            List {
                Section(header: Text("Seguridad")) {
                    Button {
                        // Reiniciar el registro facial
                        UserDefaults.standard.set(false, forKey: "FaceRegistrationCompleted")
                        FaceRegistrationManager.shared.isRegistered = false
                        showingBiometricSetup = true
                    } label: {
                        Label("Volver a registrar cara", systemImage: "faceid")
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Eliminar datos", systemImage: "trash")
                    }
                }
                
                Section(header: Text("Backup")) {
                    Button {
                        showingBackupInfo = true
                    } label: {
                        Label("Exportar datos", systemImage: "square.and.arrow.up")
                    }
                    
                    Button {
                        showingBackupInfo = true
                    } label: {
                        Label("Importar datos", systemImage: "square.and.arrow.down")
                    }
                }
                
                Section(header: Text("Acerca de")) {
                    HStack {
                        Text("Versión")
                        Spacer()
                        Text(Bundle.main.appVersion)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .sheet(isPresented: $showingBiometricSetup) {
            FaceRegistrationView()
        }
        .alert("¿Eliminar todos los datos?", isPresented: $showingDeleteConfirmation) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                // Reiniciar todo
                UserDefaults.standard.reset()
                PersistenceController.shared.deleteAll()
            }
        } message: {
            Text("Esta acción no se puede deshacer")
        }
        .alert("Próximamente", isPresented: $showingBackupInfo) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Esta función estará disponible en futuras actualizaciones")
        }
    }
}

extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

extension UserDefaults {
    func reset() {
        let dictionary = dictionaryRepresentation()
        dictionary.keys.forEach { key in
            removeObject(forKey: key)
        }
    }
} 