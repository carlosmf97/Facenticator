import UserNotifications

class FirebaseManager: NSObject, ObservableObject {
    static let shared = FirebaseManager()
    
    @Published var pendingAuthRequest: AuthRequest?
    
    struct AuthRequest {
        let siteId: UUID
        let requestId: String
        let timestamp: Date
    }
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func handleAuthRequest(_ userInfo: [AnyHashable: Any]) {
        guard let siteIdString = userInfo["siteId"] as? String,
              let siteId = UUID(uuidString: siteIdString),
              let requestId = userInfo["requestId"] as? String else {
            return
        }
        
        let request = AuthRequest(
            siteId: siteId,
            requestId: requestId,
            timestamp: Date()
        )
        
        DispatchQueue.main.async {
            self.pendingAuthRequest = request
            NotificationCenter.default.post(
                name: .authenticationRequested,
                object: nil,
                userInfo: ["request": request]
            )
        }
    }
}

// MARK: - UNUserNotificationCenter Delegate
extension FirebaseManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        handleAuthRequest(userInfo)
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        handleAuthRequest(userInfo)
        completionHandler()
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let authenticationRequested = Notification.Name("authenticationRequested")
}
