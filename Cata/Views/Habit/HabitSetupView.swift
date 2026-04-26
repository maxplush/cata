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

    private var rule: some View {
        Rectangle().fill(Color.cataSand).frame(maxWidth: .infinity).frame(height: 0.5)
    }

    var body: some View {
        ZStack {
            Color.cataBg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Text("✕")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.cataMuted)
                    }
                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.top, 28)
                .padding(.bottom, 24)

                rule

                VStack(alignment: .leading, spacing: 16) {
                    Text("DAILY HABIT".uppercased())
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.cataMuted)
                        .kerning(2)

                    Text("One thing, done every day.")
                        .font(.system(size: 22, weight: .light, design: .serif))
                        .foregroundStyle(Color.cataInk)

                    ZStack(alignment: .topLeading) {
                        if habitText.isEmpty {
                            Text("read 10 pages a day")
                                .font(.system(size: 15, design: .serif))
                                .foregroundStyle(Color.cataMuted.opacity(0.45))
                                .padding(.top, 2)
                                .allowsHitTesting(false)
                        }
                        TextEditor(text: $habitText)
                            .font(.system(size: 15, design: .serif))
                            .foregroundStyle(Color.cataInk)
                            .scrollContentBackground(.hidden)
                            .frame(height: 60)
                            .padding(.top, -4)
                    }
                    .overlay(alignment: .bottom) {
                        Rectangle().fill(Color.cataSand).frame(height: 0.5)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 28)

                VStack(alignment: .leading, spacing: 12) {
                    Text("IDEAS".uppercased())
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.cataMuted)
                        .kerning(2)

                    FlowLayout(spacing: 8) {
                        ForEach(suggestions, id: \.self) { s in
                            Button { habitText = s } label: {
                                Text(s)
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundStyle(habitText == s ? Color.cataBg : Color.cataInk)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(habitText == s ? Color.cataInk : Color.cataCard)
                            }
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 28)

                Spacer()

                rule

                Button { saveHabit() } label: {
                    HStack {
                        Text("SET HABIT")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .kerning(2)
                            .foregroundStyle(habitText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.cataMuted : Color.cataBg)
                        Spacer()
                        Text("→")
                            .font(.system(size: 16))
                            .foregroundStyle(habitText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.cataMuted : Color.cataBg)
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 20)
                    .background(habitText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.cataSand : Color.cataInk)
                }
                .disabled(habitText.trimmingCharacters(in: .whitespaces).isEmpty)
                .animation(.easeInOut(duration: 0.15), value: habitText)
            }
        }
        .onAppear {
            if let existing = habits.first(where: \.isActive) { habitText = existing.title }
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
            if x + size.width > width, x > 0 { y += rowH + spacing; x = 0; rowH = 0 }
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
            if x + size.width > bounds.maxX, x > bounds.minX { y += rowH + spacing; x = bounds.minX; rowH = 0 }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            rowH = max(rowH, size.height)
            x += size.width + spacing
        }
    }
}
