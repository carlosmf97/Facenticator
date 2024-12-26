import SwiftUI

struct ManualEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AddSiteViewModel
    @State private var name = ""
    @State private var issuer = ""
    @State private var code = ""
    @State private var isProcessing = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalles del sitio")) {
                    TextField("Nombre del sitio", text: $name)
                        .autocapitalization(.none)
                    
                    TextField("Emisor (ej: Google, Facebook)", text: $issuer)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Código de configuración")) {
                    TextField("Código de 16 dígitos", text: $code)
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
                        .onChange(of: code) { newValue in
                            code = newValue.filter { $0.isNumber || $0 == "-" }
                            if code.count > 19 { // 16 dígitos + 3 guiones
                                code = String(code.prefix(19))
                            }
                            formatCode()
                        }
                    
                    Text("Ejemplo: 1234-5678-9012-3456")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Entrada Manual")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveEntry()
                    }
                    .disabled(!isValidForm)
                }
            }
            .disabled(isProcessing)
            .overlay {
                if isProcessing {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
    
    private var isValidForm: Bool {
        !name.isEmpty && !issuer.isEmpty && code.replacingOccurrences(of: "-", with: "").count == 16
    }
    
    private func formatCode() {
        let numbers = code.replacingOccurrences(of: "-", with: "")
        var formatted = ""
        var index = numbers.startIndex
        
        for i in 0..<numbers.count {
            if i > 0 && i % 4 == 0 && index < numbers.endIndex {
                formatted += "-"
            }
            if index < numbers.endIndex {
                formatted += String(numbers[index])
                index = numbers.index(after: index)
            }
        }
        
        code = formatted
    }
    
    private func saveEntry() {
        isProcessing = true
        
        Task {
            do {
                let cleanCode = code.replacingOccurrences(of: "-", with: "")
                let site = AuthSite(
                    id: UUID().uuidString,
                    name: name,
                    issuer: issuer,
                    secret: cleanCode,
                    createdAt: Date(),
                    lastUsed: nil
                )
                
                try await viewModel.saveSite(site)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await viewModel.showError(error.localizedDescription)
            }
            
            await MainActor.run {
                isProcessing = false
            }
        }
    }
} 