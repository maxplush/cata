import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

// MARK: - Interactive Intent

struct ToggleHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Today's Habit"

    func perform() async throws -> some IntentResult {
        guard let url = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.cata.app")?
            .appendingPathComponent("cata.store") else { return .result() }

        let config = ModelConfiguration(url: url)
        let container = try ModelContainer(for: Habit.self, HabitEntry.self, configurations: config)
        let context = ModelContext(container)

        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { $0.isActive })
        guard let habit = try? context.fetch(descriptor).first else { return .result() }

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())

        if let existing = habit.entries.first(where: { cal.startOfDay(for: $0.date) == today }) {
            existing.completed.toggle()
        } else {
            let entry = HabitEntry(date: Date(), completed: true)
            entry.habit = habit
            habit.entries.append(entry)
            context.insert(entry)
        }

        try? context.save()
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

// MARK: - Timeline Entry (distinct from SwiftData HabitEntry)

struct HabitWidgetEntry: TimelineEntry {
    let date: Date
    let habitTitle: String
    let streak: Int
    let isCompleted: Bool
}

// MARK: - Provider

struct HabitProvider: TimelineProvider {
    func placeholder(in context: Context) -> HabitWidgetEntry {
        HabitWidgetEntry(date: Date(), habitTitle: "Read 10 pages", streak: 7, isCompleted: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitWidgetEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitWidgetEntry>) -> Void) {
        let entry = loadEntry()
        let midnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }

    private func loadEntry() -> HabitWidgetEntry {
        guard let url = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.cata.app")?
            .appendingPathComponent("cata.store"),
              let container = try? ModelContainer(
                  for: Habit.self, HabitEntry.self,
                  configurations: ModelConfiguration(url: url)
              )
        else {
            return HabitWidgetEntry(date: Date(), habitTitle: "—", streak: 0, isCompleted: false)
        }

        let context = container.mainContext
        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { $0.isActive })

        if let habit = try? context.fetch(descriptor).first {
            return HabitWidgetEntry(
                date: Date(),
                habitTitle: habit.title,
                streak: habit.currentStreak,
                isCompleted: habit.isCompletedToday()
            )
        }
        return HabitWidgetEntry(date: Date(), habitTitle: "—", streak: 0, isCompleted: false)
    }
}

// MARK: - Views

struct CataWidgetEntryView: View {
    var entry: HabitWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:          smallView
        case .accessoryRectangular: rectView
        case .accessoryCircular:    circleView
        default:                    smallView
        }
    }

    private var smallView: some View {
        ZStack {
            Color.cataBg
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("cata")
                        .font(.system(size: 13, weight: .bold, design: .serif))
                        .foregroundStyle(Color.cataTerra)
                    Spacer()
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.cataTerra)
                        Text("\(entry.streak)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.cataInk)
                    }
                }
                Spacer()
                Text(entry.habitTitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.cataInk)
                    .lineLimit(2)
                    .padding(.bottom, 8)
                Button(intent: ToggleHabitIntent()) {
                    HStack(spacing: 5) {
                        Image(systemName: entry.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 14))
                            .foregroundStyle(entry.isCompleted ? Color.cataTerra : Color.cataMuted)
                        Text(entry.isCompleted ? "Done" : "Mark done")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(entry.isCompleted ? Color.cataTerra : Color.cataMuted)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule().fill(entry.isCompleted
                            ? Color.cataTerra.opacity(0.12)
                            : Color.cataSand.opacity(0.3))
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(14)
        }
    }

    private var rectView: some View {
        HStack(spacing: 10) {
            Button(intent: ToggleHabitIntent()) {
                Image(systemName: entry.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(entry.isCompleted ? Color.cataTerra : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.habitTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                Text("\(entry.streak) day streak")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var circleView: some View {
        ZStack {
            if entry.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(Color.cataTerra)
            } else {
                VStack(spacing: 1) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 13))
                    Text("\(entry.streak)")
                        .font(.system(size: 15, weight: .bold))
                }
            }
        }
    }
}

// MARK: - Widget

struct CataWidget: Widget {
    let kind = "CataWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitProvider()) { entry in
            CataWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Cata Habit")
        .description("Track your daily habit and streak.")
        .supportedFamilies([.systemSmall, .accessoryRectangular, .accessoryCircular])
    }
}
