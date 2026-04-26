import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var context

    @State private var step = 0
    @State private var answers = ["", "", "", ""]
    @State private var birthYear = 1990
    @State private var showBirthYear = false

    private let questions: [(String, String)] = [
        ("Why did you download Cata?",               "What drew you here today?"),
        ("What do you want to get out of this app?",  "Be specific — it helps."),
        ("Where do you see yourself in 1 year?",      "Dream a little."),
        ("When you imagine a good life, what do you see?", "Take your time.")
    ]

    var body: some View {
        ZStack {
            Color.cataBg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Logo / wordmark
                Text("cata")
                    .font(.system(size: 18, weight: .light, design: .serif))
                    .foregroundStyle(Color.cataTerra)
                    .kerning(4)
                    .padding(.top, 64)
                    .padding(.horizontal, 32)

                thinRule.padding(.top, 20)

                // Step indicator
                HStack(spacing: 6) {
                    ForEach(0..<4) { i in
                        Rectangle()
                            .fill(i <= step ? Color.cataInk : Color.cataSand)
                            .frame(width: i == step ? 20 : 8, height: 1)
                            .animation(.spring(response: 0.3), value: step)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)
                .padding(.bottom, 28)

                if showBirthYear {
                    birthYearStep
                        .padding(.horizontal, 32)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else {
                    questionStep(index: step)
                        .padding(.horizontal, 32)
                        .id(step)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }

                Spacer()

                thinRule

                nextButton
                    .padding(.horizontal, 32)
                    .padding(.vertical, 24)
            }
        }
    }

    // MARK: - Steps

    @ViewBuilder
    private func questionStep(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(questions[index].1.uppercased())
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.cataMuted)
                .kerning(2)

            Text(questions[index].0)
                .font(.system(size: 22, weight: .light, design: .serif))
                .foregroundStyle(Color.cataInk)
                .lineSpacing(6)

            textArea(binding: $answers[index])
        }
    }

    private var birthYearStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ALMOST THERE".uppercased())
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.cataMuted)
                .kerning(2)

            Text("What year were you born?")
                .font(.system(size: 22, weight: .light, design: .serif))
                .foregroundStyle(Color.cataInk)

            Text("Used to show how many weeks you've lived — and how many are ahead.")
                .font(.system(size: 13))
                .foregroundStyle(Color.cataMuted)
                .lineSpacing(4)

            Picker("Birth Year", selection: $birthYear) {
                ForEach((1940...2008).reversed(), id: \.self) { year in
                    Text(String(year)).tag(year)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 140)
        }
    }

    private func textArea(binding: Binding<String>) -> some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(Color.cataBg)
                .frame(minHeight: 120)

            if binding.wrappedValue.isEmpty {
                Text("Write freely...")
                    .font(.system(size: 15, design: .serif))
                    .foregroundStyle(Color.cataMuted.opacity(0.5))
                    .padding(.top, 2)
                    .allowsHitTesting(false)
            }

            TextEditor(text: binding)
                .font(.system(size: 15, design: .serif))
                .foregroundStyle(Color.cataInk)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 120)
                .padding(.top, -4)
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.cataSand).frame(height: 0.5)
        }
    }

    // MARK: - Controls

    private var nextButton: some View {
        Button { advance() } label: {
            HStack {
                Text(buttonLabel.uppercased())
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .kerning(2)
                    .foregroundStyle(canAdvance ? Color.cataBg : Color.cataMuted)
                Spacer()
                Text("→")
                    .font(.system(size: 16))
                    .foregroundStyle(canAdvance ? Color.cataBg : Color.cataMuted)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(canAdvance ? Color.cataInk : Color.cataSand)
        }
        .disabled(!canAdvance)
        .animation(.easeInOut(duration: 0.2), value: canAdvance)
    }

    private var thinRule: some View {
        Rectangle()
            .fill(Color.cataSand)
            .frame(maxWidth: .infinity)
            .frame(height: 0.5)
    }

    private var buttonLabel: String {
        showBirthYear ? "Begin" : step < 3 ? "Next" : "Almost done"
    }

    private var canAdvance: Bool {
        showBirthYear || !answers[step].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func advance() {
        withAnimation(.spring(response: 0.4)) {
            if step < 3 { step += 1 }
            else if !showBirthYear { showBirthYear = true }
            else { saveProfile() }
        }
    }

    private func saveProfile() {
        context.insert(UserProfile(
            whyDownloaded: answers[0],
            wantFromApp: answers[1],
            oneYearVision: answers[2],
            goodLifeVision: answers[3],
            birthYear: birthYear
        ))
    }
}
