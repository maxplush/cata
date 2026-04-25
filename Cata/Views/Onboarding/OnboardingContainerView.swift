import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var context

    @State private var step = 0
    @State private var answers = ["", "", "", ""]
    @State private var birthYear = 1990
    @State private var showBirthYear = false

    private let questions: [(String, String)] = [
        ("Why did you download Cata?",              "What drew you here today?"),
        ("What do you want to get out of this app?", "Be specific — it helps."),
        ("Where do you see yourself in 1 year?",     "Dream a little."),
        ("When you imagine a good life, what do you see?", "Close your eyes if it helps.")
    ]

    var body: some View {
        ZStack {
            Color.cataBg.ignoresSafeArea()

            VStack(spacing: 0) {
                progressDots
                    .padding(.top, 64)
                    .padding(.bottom, 48)

                if showBirthYear {
                    birthYearStep
                        .padding(.horizontal, 28)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else {
                    questionStep(index: step)
                        .padding(.horizontal, 28)
                        .id(step)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }

                Spacer()

                nextButton
                    .padding(.horizontal, 28)
                    .padding(.bottom, 48)
            }
        }
    }

    // MARK: - Subviews

    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<4) { i in
                Capsule()
                    .fill(i <= step ? Color.cataTerra : Color.cataSand.opacity(0.35))
                    .frame(width: i == step ? 28 : 8, height: 8)
                    .animation(.spring(response: 0.3), value: step)
            }
        }
    }

    @ViewBuilder
    private func questionStep(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(questions[index].0)
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundStyle(Color.cataInk)
                .lineSpacing(4)

            Text(questions[index].1)
                .font(.system(size: 15))
                .foregroundStyle(Color.cataMuted)

            textArea(binding: $answers[index])
        }
    }

    private var birthYearStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("One last thing.")
                .font(.system(size: 28, weight: .semibold, design: .serif))
                .foregroundStyle(Color.cataInk)

            Text("Your birth year lets us show how many weeks you've lived — and how many you have ahead. Not morbid. Clarifying.")
                .font(.system(size: 15))
                .foregroundStyle(Color.cataMuted)
                .lineSpacing(4)

            Picker("Birth Year", selection: $birthYear) {
                ForEach((1940...2008).reversed(), id: \.self) { year in
                    Text(String(year)).tag(year)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .background(Color.cataCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
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
                    .foregroundStyle(Color.cataMuted.opacity(0.55))
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

    private var nextButton: some View {
        Button { advance() } label: {
            Text(buttonLabel)
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
        .animation(.easeInOut(duration: 0.2), value: canAdvance)
    }

    // MARK: - Logic

    private var buttonLabel: String {
        if showBirthYear { return "Begin" }
        return step < 3 ? "Next" : "Almost done"
    }

    private var canAdvance: Bool {
        if showBirthYear { return true }
        return !answers[step].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func advance() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if step < 3 {
                step += 1
            } else if !showBirthYear {
                showBirthYear = true
            } else {
                saveProfile()
            }
        }
    }

    private func saveProfile() {
        let profile = UserProfile(
            whyDownloaded: answers[0],
            wantFromApp: answers[1],
            oneYearVision: answers[2],
            goodLifeVision: answers[3],
            birthYear: birthYear
        )
        context.insert(profile)
    }
}
