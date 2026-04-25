import SwiftUI
import SwiftData

struct HabitSetupView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var habits: [Habit]

    @State private var habitText = ""

    private let suggestions = [
        "read 10 pages a day",
        "meditate for 10 minutes",
        "exercise for 30 minutes",
        "journal every evening",
        "no phone before 9am",
        "drink 2L of water",
        "write 500 words"
    ]

    var body: some View {
        ZStack {
            Color.cataBg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                closeButton
                    .padding(.top, 20)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Your daily habit")
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .foregroundStyle(Color.cataInk)
                    Text("Keep it simple and specific. One habit, done every day.")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.cataMuted)
                        .lineSpacing(4)
                }
                .padding(.top, 28)

                VStack(alignment: .leading, spacing: 8) {
                    Text("I want to…")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.cataMuted)
                        .textCase(.uppercase)
                        .kerning(1)
                    TextField("read 10 pages a day", text: $habitText)
                        .font(.system(size: 18))
                        .foregroundStyle(Color.cataInk)
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.cataCard))
                }
                .padding(.top, 28)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Ideas")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.cataMuted)
                        .textCase(.uppercase)
                        .kerning(1)
                    FlowLayout(spacing: 8) {
                        ForEach(suggestions, id: \.self) { s in
                            Button { habitText = s } label: {
                                Text(s)
                                    .font(.system(size: 14))
                                    .foregroundStyle(habitText == s ? Color.cataTerra : Color.cataInk)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 9)
                                    .background(
                                        Capsule().fill(habitText == s
                                            ? Color.cataTerra.opacity(0.12)
                                            : Color.cataCard)
                                    )
                            }
                        }
                    }
                }
                .padding(.top, 24)

                Spacer()

                Button { saveHabit() } label: {
                    Text("Set habit")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(habitText.trimmingCharacters(in: .whitespaces).isEmpty
                                    ? Color.cataSand.opacity(0.4)
                                    : Color.cataTerra)
                        )
                }
                .disabled(habitText.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.bottom, 48)
                .animation(.easeInOut(duration: 0.15), value: habitText)
            }
            .padding(.horizontal, 28)
        }
        .onAppear {
            if let existing = habits.first(where: \.isActive) {
                habitText = existing.title
            }
        }
    }

    private var closeButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.cataMuted)
                .padding(10)
                .background(Circle().fill(Color.cataCard))
        }
    }

    private func saveHabit() {
        habits.filter(\.isActive).forEach { $0.isActive = false }
        let habit = Habit(title: habitText.trimmingCharacters(in: .whitespacesAndNewlines))
        context.insert(habit)
        NotificationManager.shared.scheduleEveningReminder(habitTitle: habit.title)
        dismiss()
    }
}

// MARK: - Flow layout for tag chips

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowH: CGFloat = 0
        let width = proposal.width ?? .infinity

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                y += rowH + spacing
                x = 0
                rowH = 0
            }
            rowH = max(rowH, size.height)
            x += size.width + spacing
        }
        return CGSize(width: width, height: y + rowH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowH: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                y += rowH + spacing
                x = bounds.minX
                rowH = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            rowH = max(rowH, size.height)
            x += size.width + spacing
        }
    }
}
