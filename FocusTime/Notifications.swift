import UserNotifications

class Notifications {
    private let notificationCenter = UNUserNotificationCenter.current()
    
    var hasAuthorization: Bool = false
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                self.hasAuthorization = true
            } else if let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func schedule(in duration: Duration) -> String {
        let content = UNMutableNotificationContent()
        content.title = "Timer Done!"
        content.subtitle = "This is a subtitle"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: Double(duration.components.seconds), repeats: false
        )

        let id = UUID().uuidString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        notificationCenter.add(request)
        
        return id
    }
    
    func cancel(with id: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
    }
}
