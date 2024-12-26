import SwiftUI

struct HistoryCell: View {
    let entry: AuthHistory
    
    var body: some View {
        HStack {
            // Icono de estado
            Image(systemName: entry.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(entry.success ? .green : .red)
            
            VStack(alignment: .leading) {
                Text(entry.siteName)
                    .font(.headline)
                
                if !entry.success, let reason = entry.failureReason {
                    Text(formatFailureReason(reason))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Hora
            Text(formatTime(entry.timestamp))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatFailureReason(_ reason: AuthHistory.FailureReason) -> String {
        switch reason {
        case .timeout:
            return "Tiempo agotado"
        case .wrongGesture:
            return "Gesto incorrecto"
        case .livenessCheckFailed:
            return "Verificación de vida fallida"
        case .faceIdMismatch:
            return "Face ID no coincide"
        case .tooManyAttempts:
            return "Demasiados intentos"
        }
    }
} 