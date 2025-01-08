import SwiftUI
import CoreData

struct HistoryCell: View {
    let item: HistoryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.wrappedSiteIssuer)
                    .font(AppTheme.Typography.title3)
                Spacer()
                Image(systemName: item.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(item.success ? .green : .red)
            }
            
            Text(item.wrappedSiteName)
                .font(AppTheme.Typography.body)
                .foregroundColor(.secondary)
            
            if let failureReason = item.failureReason {
                Text(failureReason)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.red)
            }
            
            Text(formatDate(item.wrappedTimestamp))
                .font(AppTheme.Typography.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
} 
