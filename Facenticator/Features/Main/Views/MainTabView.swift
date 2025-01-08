import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @Namespace private var animation
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                SiteListView()
                    .tag(0)
                
                HistoryView()
                    .tag(1)
                
                SettingsView()
                    .tag(2)
            }
            
            // Custom Tab Bar
            HStack {
                ForEach(0..<3) { index in
                    Spacer()
                    TabButton(
                        selectedTab: $selectedTab,
                        title: tabTitle(for: index),
                        icon: tabIcon(for: index),
                        index: index,
                        animation: animation
                    )
                    Spacer()
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(AppTheme.Colors.surface)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: -5)
            )
            .padding(.horizontal)
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Sitios"
        case 1: return "Historial"
        case 2: return "Ajustes"
        default: return ""
        }
    }
    
    private func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "key.fill"
        case 1: return "clock.fill"
        case 2: return "gear"
        default: return ""
        }
    }
}

struct TabButton: View {
    @Binding var selectedTab: Int
    let title: String
    let icon: String
    let index: Int
    let animation: Namespace.ID
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(selectedTab == index ? AppTheme.Colors.primary : .gray)
                    .scaleEffect(selectedTab == index ? 1.2 : 1.0)
                
                Text(title)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(selectedTab == index ? AppTheme.Colors.primary : .gray)
            }
            .overlay(
                selectedTab == index ?
                Rectangle()
                    .fill(AppTheme.Colors.primary)
                    .frame(height: 3)
                    .matchedGeometryEffect(id: "TAB", in: animation)
                    .offset(y: 28)
                : nil
            )
        }
    }
} 