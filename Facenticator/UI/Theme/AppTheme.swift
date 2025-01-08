import SwiftUI

enum AppTheme {
    struct Colors {
        static let primary = Color("PrimaryColor", bundle: nil)
        static let background = Color("BackgroundColor", bundle: nil)
        static let surface = Color("SurfaceColor", bundle: nil)
        static let text = Color("TextColor", bundle: nil)
        static let error = Color.red
    }
    
    struct Typography {
        static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
        static let title = Font.system(.title, design: .rounded).weight(.semibold)
        static let title2 = Font.system(.title2, design: .rounded).weight(.semibold)
        static let title3 = Font.system(.title3, design: .rounded).weight(.semibold)
        static let body = Font.system(.body, design: .rounded)
        static let caption = Font.system(.caption, design: .rounded)
    }
} 