import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var showingDeleteConfirmation = false
    @State private var itemToDelete: IndexSet?
    
    var body: some View {
        VStack(spacing: 0) {
            // Barra de título personalizada
            HStack {
                Text("Historial")
                    .font(AppTheme.Typography.title)
                    .padding(.leading)
                Spacer()
            }
            .padding(.vertical)
            .background(Color(.systemBackground))
            
            // Contenido principal
            if viewModel.historyItems.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No hay historial")
                        .font(AppTheme.Typography.title3)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredItems, id: \.self) { item in
                            HistoryCell(item: item)
                                .padding(.horizontal)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                )
                                .padding(.horizontal, 16)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        if let index = viewModel.historyItems.firstIndex(of: item) {
                                            itemToDelete = IndexSet([index])
                                            showingDeleteConfirmation = true
                                        }
                                    } label: {
                                        Label("Eliminar", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .background(Color(.systemGroupedBackground))
                .refreshable {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    viewModel.loadHistory()
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Buscar en historial")
        .alert("¿Eliminar este registro?", isPresented: $showingDeleteConfirmation) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                if let indexSet = itemToDelete {
                    viewModel.clearHistory()
                    itemToDelete = nil
                }
            }
        } message: {
            Text("Esta acción no se puede deshacer")
        }
    }
}
