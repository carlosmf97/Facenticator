import SwiftUI
import CodeScanner

struct AddSiteView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddSiteViewModel()
    @State private var showingScanner = false
    @State private var showingManualEntry = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Imagen ilustrativa
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)
                    .padding()
                
                // Botones de acción
                VStack(spacing: 15) {
                    Button {
                        showingScanner = true
                    } label: {
                        HStack {
                            Image(systemName: "qrcode")
                            Text("Escanear código QR")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button {
                        showingManualEntry = true
                    } label: {
                        HStack {
                            Image(systemName: "keyboard")
                            Text("Entrada manual")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.secondary.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Añadir Sitio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                CodeScannerView(codeTypes: [.qr]) { result in
                    handleScan(result: result)
                }
            }
            .sheet(isPresented: $showingManualEntry) {
                ManualEntryView(viewModel: viewModel)
            }
            .alert("Error", isPresented: $viewModel.showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    private func handleScan(result: Result<ScanResult, ScanError>) {
        showingScanner = false
        
        switch result {
        case .success(let result):
            Task {
                await viewModel.processQRCode(result.string)
            }
        case .failure:
            viewModel.showError("No se pudo leer el código QR")
        }
    }
}
