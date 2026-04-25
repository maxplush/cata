import SwiftUI
import SwiftData

struct HabitTrackerView: View {
    @Bindable var habit: Habit
    @Environment(\.modelContext) private var context
    @State private var checkBounce = false
    @State private var prevCompleted = false

    var body: some View {
        VStack(spacing: 0) {
            flowerSection
            controlRow
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    // MARK: - Sections

    private var flowerSection: some View {
        ZStack {
            LinearGradient(
                colors: [Color.cataSage.opacity(0.09), Color.cataTerra.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 18) {
                FlowerView(streak: habit.currentStreak)
                    .frame(width: 140, height: 180)

                VStack(spacing: 5) {
                    Text("\(habit.currentStreak)")
                        .font(.system(size: 52, weight: .bold, design: .serif))
                        .foregroundStyle(Color.cataInk)
                        .contentTransition(.numericText())
                    Text(habit.currentStreak == 1 ? "day streak" : "day streak")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.cataMuted)
                        .textCase(.uppercase)
                        .kerning(1.2)
                }
            }
            .padding(.vertical, 32)
        }
    }

    private var controlRow: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text(habit.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.cataInk)
                Text(subtitleText)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.cataMuted)
            }
            Spacer()
            checkButton
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.cataCard)
    }

    private var subtitleText: String {
        if habit.isCompletedToday() { return "Completed today" }
        let rate = Int(habit.completionRateLast7Days * 100)
        return "\(rate)% this week"
    }

    private var checkButton: some View {
        let completed = habit.isCompletedToday()
        return Button { toggle() } label: {
            ZStack {
                Circle()
                    .fill(completed ? Color.cataTerra : Color.cataSand.opacity(0.28))
                    .frame(width: 54, height: 54)
                Image(systemName: completed ? "checkmark" : "circle")
                    .font(.system(size: completed ? 18 : 22, weight: .semibold))
                    .foregroundStyle(completed ? .white : Color.cataMuted)
            }
            .scaleEffect(checkBounce ? 1.18 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: checkBounce)
        }
        .buttonStyle(.plain)
        .onChange(of: habit.isCompletedToday()) { _, isNowDone in
            guard isNowDone else { return }
            checkBounce = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { checkBounce = false }
        }
    }

    // MARK: - Logic

    private func toggle() {
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

        NotificationManager.shared.updateNudgesIfNeeded(habit: habit)
    }
}
