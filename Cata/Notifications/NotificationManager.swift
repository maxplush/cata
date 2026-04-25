import UserNotifications
import Foundation

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    // Evening reminder if habit not checked off by 8pm
    func scheduleEveningReminder(habitTitle: String) {
        let content = UNMutableNotificationContent()
        content.title = "How'd your day go?"
        content.body = "Did you \(habitTitle) today?"
        content.sound = .default

        var comps = DateComponents()
        comps.hour = 20
        comps.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let req = UNNotificationRequest(identifier: "evening_reminder", content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["evening_reminder"])
        center.add(req)
    }

    // Personalized nudge 8h after morning check-in
    func scheduleEveningNudge(profile: UserProfile, intention: String) {
        let content = UNMutableNotificationContent()
        content.title = "Evening check-in"
        content.body = "How's your progress on: \(intention)?"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 8 * 3600, repeats: false)
        let id = "daily_nudge_\(Calendar.current.startOfDay(for: Date()).timeIntervalSince1970)"
        let req = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }

    // Smart nudges based on habit performance
    func updateNudgesIfNeeded(habit: Habit) {
        let rate   = habit.completionRateLast7Days
        let missed = habit.missedCountLast7Days
        let center = UNUserNotificationCenter.current()

        if missed >= 3 {
            let messages = [
                "You've missed a few days. What's getting in the way?",
                "Small streaks build big lives. Ready to restart?",
                "Progress isn't lost — it's waiting for you."
            ]
            let content = UNMutableNotificationContent()
            content.title = "A gentle nudge"
            content.body = messages.randomElement()!
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
            let req = UNNotificationRequest(identifier: "reflection_nudge", content: content, trigger: trigger)
            center.removePendingNotificationRequests(withIdentifiers: ["reflection_nudge"])
            center.add(req)
        }

        if rate > 0.8 {
            let content = UNMutableNotificationContent()
            content.title = "You're on fire"
            content.body = "80%+ completion rate on \"\(habit.title)\" — ready to level up?"
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7200, repeats: false)
            let req = UNNotificationRequest(identifier: "stretch_goal", content: content, trigger: trigger)
            center.removePendingNotificationRequests(withIdentifiers: ["stretch_goal"])
            center.add(req)
        }
    }
}
