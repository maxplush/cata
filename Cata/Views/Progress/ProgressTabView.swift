import SwiftUI
import SwiftData

struct ProgressTabView: View {
    @Query(sort: \Habit.createdAt, order: .reverse) private var habits: [Habit]
    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]

    private var active: Habit? { habits.first(where: \.isActive) }

    private var rule: some View {
        Rectangle().fill(Color.cataSand).frame(maxWidth: .infinity).frame(height: 0.5)
            .padding(.horizontal, 24)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cataBg.ignoresSafeArea()

                if let habit = active {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            statsSection(habit)
                            rule
                            calendarSection(habit)
                            rule
                            weeklySection(habit)
                        }
                        .padding(.bottom, 60)
                    }
                } else {
                    emptyState
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func statsSection(_ habit: Habit) -> some View {
        HStack(spacing: 0) {
            statCell("\(habit.currentStreak)", "streak", accent: true)
            Rectangle().fill(Color.cataSand).frame(width: 0.5, height: 40)
            statCell("\(Int(habit.completionRateLast7Days * 100))%", "7-day rate")
            Rectangle().fill(Color.cataSand).frame(width: 0.5, height: 40)
            statCell("\(checkIns.count)", "check-ins")
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
    }

    private func statCell(_ value: String, _ label: String, accent: Bool = false) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .light, design: .serif))
                .foregroundStyle(accent ? Color.cataTerra : Color.cataInk)
                .contentTransition(.numericText())
            Text(label.uppercased())
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.cataMuted)
                .kerning(1.5)
        }
        .frame(maxWidth: .infinity)
    }

    private func calendarSection(_ habit: Habit) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("CALENDAR".uppercased())
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.cataMuted)
                .kerning(2)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
            CalendarStreakView(habit: habit)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
        }
    }

    private func weeklySection(_ habit: Habit) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("THIS WEEK".uppercased())
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.cataMuted)
                .kerning(2)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
            WeeklySummaryView(habit: habit, checkIns: checkIns)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("no habit set yet")
                .font(.system(size: 15, design: .serif))
                .foregroundStyle(Color.cataMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
    }
}
