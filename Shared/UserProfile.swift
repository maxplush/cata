import SwiftData
import Foundation

@Model
final class UserProfile {
    var id: UUID = UUID()
    var whyDownloaded: String = ""
    var wantFromApp: String = ""
    var oneYearVision: String = ""
    var goodLifeVision: String = ""
    var birthYear: Int = 1990
    var createdAt: Date = Date()

    init(
        whyDownloaded: String,
        wantFromApp: String,
        oneYearVision: String,
        goodLifeVision: String,
        birthYear: Int
    ) {
        self.whyDownloaded = whyDownloaded
        self.wantFromApp = wantFromApp
        self.oneYearVision = oneYearVision
        self.goodLifeVision = goodLifeVision
        self.birthYear = birthYear
    }
}
