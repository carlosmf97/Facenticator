import SwiftUI
import CodeScanner

struct AddSiteView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SiteListViewModel
    @State private var name = ""
    @State private var issuer = ""
    @State private var secret = ""
    @State private var showingScanner = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Información del sitio") {
                    TextField("Nombre de usuario", text: $name)
                        .textContentType(.username)
                        .autocapitalization(.none)
                    
                    TextField("Nombre del sitio", text: $issuer)
                        .textContentType(.organizationName)
                    
                    TextField("Clave secreta", text: $secret)
                        .autocapitalization(.none)
                        .textContentType(.oneTimeCode)
                }
                
                Section {
                    Button {
                        showingScanner = true
                    } label: {
                        HStack {
                            Image(systemName: "qrcode.viewfinder")
                            Text("Escanear código QR")
                        }
                    }
                }
                
                Section {
                    Button("Guardar", action: saveSite)
                        .disabled(name.isEmpty || issuer.isEmpty || secret.isEmpty)
                }
            }
            .navigationTitle("Añadir sitio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                CodeScannerView(
                    codeTypes: [.qr],
                    simulatedData: "otpauth://totp/Example:john.doe?secret=JBSWY3DPEHPK3PXP&issuer=Example",
                    completion: handleScan
                )
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveSite() {
        viewModel.addSite(name: name, issuer: issuer, secret: secret)
        dismiss()
    }
    
    private func handleScan(result: Result<ScanResult, ScanError>) {
        showingScanner = false
        
        switch result {
        case .success(let result):
            if let url = URL(string: result.string),
               url.scheme == "otpauth",
               url.host == "totp" {
                parseOTPAuthURL(url)
            } else {
                showError(message: "Código QR no válido")
            }
        case .failure:
            showError(message: "Error al escanear el código")
        }
    }
    
    private func parseOTPAuthURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let secret = components.queryItems?.first(where: { $0.name == "secret" })?.value else {
            showError(message: "Código QR no válido")
            return
        }
        
        self.secret = secret
        
        if let issuer = components.queryItems?.first(where: { $0.name == "issuer" })?.value {
            self.issuer = issuer
        }
        
        let path = url.path.dropFirst() // Remove leading "/"
        if let colonIndex = path.firstIndex(of: ":") {
            let nameStart = path.index(after: colonIndex)
            self.name = String(path[nameStart...])
        } else {
            self.name = String(path)
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
} 