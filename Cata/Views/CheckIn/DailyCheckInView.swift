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

    private let questions: [(label: String, prompt: String)] = [
        ("GRATITUDE",    "What are you grateful for today?"),
        ("INTENTION",    "What's one thing you want to accomplish?"),
        ("RELEASE",      "What do you want to stop doing today?")
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

    private var flowView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Button { dismiss() } label: {
                    Text("✕")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.cataMuted)
                }
                Spacer()
                HStack(spacing: 5) {
                    ForEach(0..<3) { i in
                        Rectangle()
                            .fill(i <= step ? Color.cataInk : Color.cataSand)
                            .frame(width: i == step ? 16 : 8, height: 1)
                            .animation(.spring(response: 0.3), value: step)
                    }
                }
                Spacer()
                Color.clear.frame(width: 20)
            }
            .padding(.horizontal, 32)
            .padding(.top, 28)
            .padding(.bottom, 24)

            thinRule

            VStack(alignment: .leading, spacing: 16) {
                Text(questions[step].label)
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.cataTerra)
                    .kerning(2)

                Text(questions[step].prompt)
                    .font(.system(size: 22, weight: .light, design: .serif))
                    .foregroundStyle(Color.cataInk)
                    .lineSpacing(6)

                textArea(binding: currentAnswer)
            }
            .padding(.horizontal, 32)
            .padding(.top, 28)
            .id(step)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))

            Spacer()

            thinRule

            Button {
                withAnimation(.spring(response: 0.4)) { advance() }
            } label: {
                HStack {
                    Text((step < 2 ? "Next" : "Done").uppercased())
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .kerning(2)
                        .foregroundStyle(canAdvance ? Color.cataBg : Color.cataMuted)
                    Spacer()
                    Text("→")
                        .font(.system(size: 16))
                        .foregroundStyle(canAdvance ? Color.cataBg : Color.cataMuted)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 20)
                .background(canAdvance ? Color.cataInk : Color.cataSand)
            }
            .disabled(!canAdvance)
            .animation(.easeInOut(duration: 0.15), value: canAdvance)
        }
    }

    private var completionView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            VStack(alignment: .leading, spacing: 12) {
                Text("✓")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.cataTerra)
                Text("You're set for today.")
                    .font(.system(size: 26, weight: .light, design: .serif))
                    .foregroundStyle(Color.cataInk)
                Text("Now go make it count.")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundStyle(Color.cataMuted)
            }
            .padding(.horizontal, 32)
            Spacer()
            thinRule
            Button { dismiss() } label: {
                HStack {
                    Text("CLOSE")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .kerning(2)
                        .foregroundStyle(Color.cataBg)
                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 20)
                .background(Color.cataInk)
            }
        }
    }

    private func textArea(binding: Binding<String>) -> some View {
        ZStack(alignment: .topLeading) {
            if binding.wrappedValue.isEmpty {
                Text("Write freely...")
                    .font(.system(size: 15, design: .serif))
                    .foregroundStyle(Color.cataMuted.opacity(0.45))
                    .padding(.top, 2)
                    .allowsHitTesting(false)
            }
            TextEditor(text: binding)
                .font(.system(size: 15, design: .serif))
                .foregroundStyle(Color.cataInk)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 130)
                .padding(.top, -4)
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.cataSand).frame(height: 0.5)
        }
    }

    private var thinRule: some View {
        Rectangle().fill(Color.cataSand).frame(maxWidth: .infinity).frame(height: 0.5)
    }

    private var canAdvance: Bool {
        !currentAnswer.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func advance() {
        if step < 2 { step += 1 }
        else { save(); withAnimation { done = true } }
    }

    private func save() {
        context.insert(DailyCheckIn(
            gratitude: gratitude,
            accomplishment: accomplishment,
            stopDoing: stopDoing
        ))
        if let profile = profiles.first {
            NotificationManager.shared.scheduleEveningNudge(profile: profile, intention: accomplishment)
        }
    }
}
