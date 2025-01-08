import SwiftUI
import Firebase

@main
struct FacenticatorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared
    @StateObject private var biometricManager = BiometricManager.shared
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    
    
    var body: some Scene {
        WindowGroup {
            if biometricManager.isAuthenticated {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .onAppear {
                        // Solicitar permisos de notificaciones al iniciar la app
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                            if granted {
                                DispatchQueue.main.async {
                                    UIApplication.shared.registerForRemoteNotifications()
                                }
                            }
                            if let error = error {
                                print("Error solicitando permisos de notificación: \(error)")
                            }
                        }
                    }
            } else {
                AppLockView()
            }
        }
    }
}
