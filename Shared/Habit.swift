import SwiftData
import Foundation

@Model
final class Habit {
    var id: UUID = UUID()
    var title: String = ""
    var createdAt: Date = Date()
    var isActive: Bool = true

    @Relationship(deleteRule: .cascade) var entries: [HabitEntry] = []

    init(title: String) {
        self.title = title
    }

    var currentStreak: Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let completed = Set(entries.filter(\.completed).map { cal.startOfDay(for: $0.date) })
        var streak = 0
        var day = today
        while completed.contains(day) {
            streak += 1
            day = cal.date(byAdding: .day, value: -1, to: day)!
        }
        return streak
    }

    var completionRateLast7Days: Double {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let habitStart = cal.startOfDay(for: createdAt)
        var done = 0
        var total = 0
        for i in 0..<7 {
            let day = cal.date(byAdding: .day, value: -i, to: today)!
            if day >= habitStart {
                total += 1
                if entries.contains(where: { cal.startOfDay(for: $0.date) == day && $0.completed }) {
                    done += 1
                }
            }
        }
        return total > 0 ? Double(done) / Double(total) : 0
    }

    var missedCountLast7Days: Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let habitStart = cal.startOfDay(for: createdAt)
        var missed = 0
        for i in 0..<7 {
            let day = cal.date(byAdding: .day, value: -i, to: today)!
            if day >= habitStart,
               !entries.contains(where: { cal.startOfDay(for: $0.date) == day && $0.completed }) {
                missed += 1
            }
        }
        return missed
    }

    func isCompletedToday() -> Bool {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return entries.contains { cal.startOfDay(for: $0.date) == today && $0.completed }
    }

    func isCompleted(on date: Date) -> Bool {
        let cal = Calendar.current
        let day = cal.startOfDay(for: date)
        return entries.contains { cal.startOfDay(for: $0.date) == day && $0.completed }
    }
}
