import SwiftUI
import SwiftData

struct DailyCheckInView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]

    @State private var step = 0
    @State private var gratitude = ""
    @State private var accomplishment = ""
    @State private var stopDoing = ""
    @State private var done = false

    private let questions: [(title: String, icon: String, hint: String)] = [
        ("What are you grateful for today?",          "sun.max.fill",    "Even small things count."),
        ("What's one thing you want to accomplish?",  "target",          "Just one. Make it real."),
        ("What do you want to stop doing today?",     "xmark.circle.fill","Name it to tame it.")
    ]

    private var currentAnswer: Binding<String> {
        [_gratitude, _accomplishment, _stopDoing][step].projectedValue
    }

    var body: some View {
        ZStack {
            Color.cataBg.ignoresSafeArea()
            if done { completionView } else { flowView }
        }
    }

    // MARK: - Flow

    private var flowView: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 20)

            Spacer()

            VStack(alignment: .leading, spacing: 22) {
                HStack(spacing: 10) {
                    Image(systemName: questions[step].icon)
                        .font(.system(size: 18))
                        .foregroundStyle(Color.cataTerra)
                    Text(questions[step].hint)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.cataMuted)
                }

                Text(questions[step].title)
                    .font(.system(size: 26, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.cataInk)
                    .lineSpacing(4)

                textArea(binding: currentAnswer)
            }
            .padding(.horizontal, 28)
            .id(step)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))

            Spacer()

            Button {
                withAnimation(.spring(response: 0.4)) { advance() }
            } label: {
                Text(step < 2 ? "Next" : "Done")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(canAdvance ? Color.cataTerra : Color.cataSand.opacity(0.4))
                    )
            }
            .disabled(!canAdvance)
            .padding(.horizontal, 28)
            .padding(.bottom, 48)
            .animation(.easeInOut(duration: 0.2), value: canAdvance)
        }
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.cataMuted)
                    .padding(10)
                    .background(Circle().fill(Color.cataCard))
            }
            Spacer()
            HStack(spacing: 7) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(i <= step ? Color.cataTerra : Color.cataSand.opacity(0.35))
                        .frame(width: 8, height: 8)
                        .animation(.spring(response: 0.3), value: step)
                }
            }
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
    }

    private func textArea(binding: Binding<String>) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cataCard)
                .frame(minHeight: 130)

            if binding.wrappedValue.isEmpty {
                Text("Write freely...")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.cataMuted.opacity(0.5))
                    .padding(16)
                    .allowsHitTesting(false)
            }

            TextEditor(text: binding)
                .font(.system(size: 16))
                .foregroundStyle(Color.cataInk)
                .scrollContentBackground(.hidden)
                .padding(12)
                .frame(minHeight: 130)
        }
    }

    // MARK: - Completion

    private var completionView: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.cataTerra.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "checkmark")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(Color.cataTerra)
            }
            VStack(spacing: 8) {
                Text("You're set for today.")
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.cataInk)
                Text("Now go make it count.")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.cataMuted)
            }
            Spacer()
            Button { dismiss() } label: {
                Text("Close")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.cataTerra)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.cataTerra.opacity(0.1)))
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 48)
        }
    }

    // MARK: - Logic

    private var canAdvance: Bool {
        !currentAnswer.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func advance() {
        if step < 2 {
            step += 1
        } else {
            save()
            withAnimation { done = true }
        }
    }

    private func save() {
        let checkIn = DailyCheckIn(
            gratitude: gratitude,
            accomplishment: accomplishment,
            stopDoing: stopDoing
        )
        context.insert(checkIn)

        if let profile = profiles.first {
            NotificationManager.shared.scheduleEveningNudge(
                profile: profile,
                intention: accomplishment
            )
        }
    }
}
