import SwiftData
import Foundation

@Model
final class HabitEntry {
    var id: UUID = UUID()
    var date: Date = Date()
    var completed: Bool = false

    var habit: Habit?

    init(date: Date = Date(), completed: Bool = true) {
        self.date = date
        self.completed = completed
    }
}
