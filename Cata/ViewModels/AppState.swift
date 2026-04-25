import SwiftUI

@Observable
class AppState {
    var selectedTab: Tab = .home

    enum Tab: String, CaseIterable {
        case home, progress, life

        var icon: String {
            switch self {
            case .home:     return "house.fill"
            case .progress: return "chart.bar.fill"
            case .life:     return "circle.grid.3x3.fill"
            }
        }

        var label: String {
            switch self {
            case .home:     return "Home"
            case .progress: return "Progress"
            case .life:     return "Life"
            }
        }
    }
}
