import SwiftUI
import SwiftData

struct ProgressTabView: View {
    @Query(sort: \Habit.createdAt, order: .reverse) private var habits: [Habit]
    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]

    private var active: Habit? { habits.first(where: \.isActive) }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cataBg.ignoresSafeArea()

                if let habit = active {
                    ScrollView {
                        VStack(spacing: 20) {
                            statsRow(habit)
                                .padding(.top, 4)
                            CalendarStreakView(habit: habit)
                            WeeklySummaryView(habit: habit, checkIns: checkIns)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                } else {
                    emptyState
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func statsRow(_ habit: Habit) -> some View {
        HStack(spacing: 10) {
            statCard("\(habit.currentStreak)",            "Streak",     "flame.fill",                .cataTerra)
            statCard("\(Int(habit.completionRateLast7Days * 100))%", "This week",  "chart.line.uptrend.xyaxis", .cataSage)
            statCard("\(checkIns.count)",                 "Check-ins",  "sun.horizon.fill",          .cataSand)
        }
    }

    private func statCard(_ value: String, _ label: String, _ icon: String, _ color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 17))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(Color.cataInk)
                .contentTransition(.numericText())
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.cataMuted)
                .textCase(.uppercase)
                .kerning(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.cataCard))
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "chart.bar")
                .font(.system(size: 38))
                .foregroundStyle(Color.cataMuted.opacity(0.35))
            Text("Set a habit to see your progress")
                .font(.system(size: 16))
                .foregroundStyle(Color.cataMuted)
        }
    }
}
