import SwiftData
import Foundation

@Model
final class DailyCheckIn {
    var id: UUID = UUID()
    var date: Date = Date()
    var gratitude: String = ""
    var accomplishment: String = ""
    var stopDoing: String = ""

    init(gratitude: String, accomplishment: String, stopDoing: String) {
        self.gratitude = gratitude
        self.accomplishment = accomplishment
        self.stopDoing = stopDoing
    }
}
