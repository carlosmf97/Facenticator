import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.historyGroups.keys.sorted().reversed(), id: \.self) { date in
                    Section(header: Text(formatDate(date))) {
                        ForEach(viewModel.historyGroups[date] ?? []) { entry in
                            HistoryCell(entry: entry)
                        }
                    }
                }
            }
            .navigationTitle("Historial")
            .overlay {
                if viewModel.historyGroups.isEmpty {
                    ContentUnavailableView(
                        "Sin historial",
                        systemImage: "clock",
                        description: Text("Las autenticaciones aparecerán aquí")
                    )
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Hoy"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Ayer"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

class HistoryViewModel: ObservableObject {
    @Published var historyGroups: [Date: [AuthHistory]] = [:]
    
    private let storageService = StorageService()
    
    init() {
        Task {
            await loadHistory()
        }
    }
    
    @MainActor
    private func loadHistory() async {
        do {
            let history = try await storageService.loadHistory()
            
            // Agrupar por fecha
            historyGroups = Dictionary(grouping: history) { entry in
                Calendar.current.startOfDay(for: entry.timestamp)
            }
        } catch {
            print("Error loading history: \(error)")
        }
    }
} 
