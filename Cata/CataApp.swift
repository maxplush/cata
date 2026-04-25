import SwiftUI
import SwiftData

@main
struct CataApp: App {
    let container: ModelContainer
    @State private var appState = AppState()

    init() {
        // Use App Group container so the widget can read the same store
        let groupURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.cata.app")?
            .appendingPathComponent("cata.store")

        do {
            if let url = groupURL {
                let config = ModelConfiguration(url: url)
                container = try ModelContainer(
                    for: UserProfile.self, Habit.self, HabitEntry.self, DailyCheckIn.self,
                    configurations: config
                )
            } else {
                container = try ModelContainer(
                    for: UserProfile.self, Habit.self, HabitEntry.self, DailyCheckIn.self
                )
            }
        } catch {
            fatalError("ModelContainer init failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .environment(appState)
                .onAppear {
                    NotificationManager.shared.requestPermission()
                }
        }
    }
}
