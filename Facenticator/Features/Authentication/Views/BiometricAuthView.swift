import SwiftUI

struct BiometricAuthView: View {
    @Binding var showBiometricAuth: Bool
    @Binding var authResult: Bool?
    @StateObject private var biometricManager = BiometricManager.shared
    @StateObject private var faceManager = FaceRegistrationManager.shared
    @State private var showStatusMessage = false
    @State private var remainingTime = 20
    @State private var remainingAttempts = 2
    @State private var statusMessage = ""
    @State private var statusIcon = "checkmark.circle.fill" 
    @State private var statusColor = Color.green
    @State private var isTimerActive = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            if biometricManager.skipVerificationIntro {
                FaceRegistrationView()
                    .onAppear {
                        isTimerActive = true
                    }
            } else {
                VerificationIntroView(showVerification: $showBiometricAuth)
            }
            
            // Overlay para mensajes y timer
            VStack {
                Spacer()
                
                if showStatusMessage {
                    VStack(spacing: 12) {
                        Image(systemName: statusIcon)
                            .font(.system(size: 50))
                            .foregroundColor(statusColor)
                        Text(statusMessage)
                            .font(AppTheme.Typography.title3)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                }
                
                Spacer()
                
                // Timer
                if isTimerActive {
                    Text("\(remainingTime)")
                        .font(.system(.title, design: .monospaced))
                        .foregroundColor(remainingTime <= 5 ? .red : .secondary)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .padding(.bottom, 50)
                }
            }
        }
        .onReceive(timer) { _ in
            if isTimerActive && remainingTime > 0 {
                remainingTime -= 1
            } else if isTimerActive && remainingTime == 0 {
                handleTimeOut()
            }
        }
        .onChange(of: faceManager.registrationProgress) { progress in
            if progress >= 1.0 {
                showSuccessMessage()
            } else if progress < 0 { // Asumiendo que progress < 0 indica fallo
                handleFailedAttempt()
            }
        }
    }
    
    private func handleFailedAttempt() {
        if remainingAttempts > 1 {
            showFailureMessage()
        } else {
            showFinalFailureMessage()
        }
    }
    
    private func showSuccessMessage() {
        isTimerActive = false
        withAnimation {
            statusIcon = "checkmark.circle.fill"
            statusColor = .green
            statusMessage = "¡Verificación exitosa!"
            showStatusMessage = true
        }
        
        HapticManager.shared.notification(type: .success)
        HapticManager.shared.impact(style: .heavy)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            authResult = true
            showBiometricAuth = false
        }
    }
    
    private func showFailureMessage() {
        remainingAttempts -= 1
        remainingTime = 20
        
        withAnimation {
            statusIcon = "exclamationmark.circle.fill"
            statusColor = .orange
            statusMessage = "Gesto incorrecto\nInténtalo de nuevo"
            showStatusMessage = true
        }
        
        HapticManager.shared.notification(type: .error)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showStatusMessage = false
            }
            faceManager.resetVerification()
        }
    }
    
    private func showFinalFailureMessage() {
        isTimerActive = false
        withAnimation {
            statusIcon = "xmark.circle.fill"
            statusColor = .red
            statusMessage = "Verificación fallida"
            showStatusMessage = true
        }
        
        HapticManager.shared.notification(type: .error)
        HapticManager.shared.impact(style: .heavy)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            authResult = false
            showBiometricAuth = false
        }
    }
    
    private func handleTimeOut() {
        if remainingAttempts > 1 {
            showFailureMessage()
        } else {
            showFinalFailureMessage()
        }
    }
} 
