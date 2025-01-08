import SwiftUI
import SDWebImageSwiftUI

struct SiteCell: View {
    let site: Site
    @State private var code: String = "------"
    @State private var timeRemaining: Int = 30
    @State private var showCopied = false
    @State private var isAnimating = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var progress: Double {
        Double(timeRemaining) / 30.0
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            // Contenido principal de la celda
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    // Logo
                    if let logoUrl = site.logoUrl {
                        WebImage(url: URL(string: logoUrl))
                            .onSuccess { image, data, cacheType in
                                // Imagen cargada exitosamente
                            }
                            .resizable()
                            .renderingMode(.original)
                            .indicator(.activity)
                            .animation(.easeInOut(duration: 0.5), value: true)
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                            )
                    } else {
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                            .frame(width: 40, height: 40)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(site.wrappedIssuer)
                            .font(AppTheme.Typography.title3)
                        
                        Text(site.wrappedName)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Código y temporizador
                    VStack(alignment: .trailing) {
                        Text(code)
                            .font(.system(.title2, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.Colors.primary)
                            .scaleEffect(isAnimating ? 1.2 : 1.0)
                        
                        // Barra de progreso circular
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                                .frame(width: 24, height: 24)
                            
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(AppTheme.Colors.primary, lineWidth: 2)
                                .frame(width: 24, height: 24)
                                .rotationEffect(.degrees(-90))
                            
                            Text("\(timeRemaining)")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
            .background(AppTheme.Colors.surface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Mensaje de copiado como overlay independiente
            if showCopied {
                Text("¡Copiado!")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(4)
                    .offset(y: -50) // Ajusta este valor según necesites
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1) // Asegura que esté por encima de todo
            }
        }
        .onTapGesture {
            copyCode()
        }
        .onReceive(timer) { _ in
            updateTimeRemaining()
            if timeRemaining == 30 {
                updateCode()
            }
        }
        .onAppear {
            updateCode()
            updateTimeRemaining()
        }
    }
    
    private func copyCode() {
        UIPasteboard.general.string = code
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isAnimating = true
            showCopied = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation {
                isAnimating = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showCopied = false
            }
        }
        
        HapticManager.shared.notification(type: .success)
    }
    
    private func updateCode() {
        // Generar un código aleatorio de 6 dígitos para demo
        code = String(format: "%06d", Int.random(in: 0...999999))
    }
    
    private func updateTimeRemaining() {
        timeRemaining = Int(30 - (Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 30)))
        if timeRemaining == 30 {
            updateCode()
        }
    }
} 
