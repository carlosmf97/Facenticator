import SwiftUI
import SDWebImageSwiftUI

struct AuthRequestView: View {
    let site: Site
    @Binding var isPresented: Bool
    @State private var authResult: Bool?
    
    var body: some View {
        BiometricAuthView(showBiometricAuth: $isPresented, authResult: $authResult)
            .onChange(of: authResult) { newValue in
                if newValue == true {
                    // Mostrar mensaje de éxito
                    HapticManager.shared.notification(type: .success)
                    withAnimation {
                        isPresented = false
                    }
                }
            }
    }
}
