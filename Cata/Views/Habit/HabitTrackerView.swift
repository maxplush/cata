import SwiftUI
import SwiftData

struct HabitTrackerView: View {
    @Bindable var habit: Habit
    @Environment(\.modelContext) private var context
    @State private var checkBounce = false
    @State private var showFlower = false
    @State private var burst = false

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                mainRow
                if showFlower {
                    flowerRow
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }

            // Petal burst overlay
            if burst {
                PetalBurst()
                    .allowsHitTesting(false)
            }
        }
        .onAppear { showFlower = habit.currentStreak > 0 }
        .onChange(of: habit.currentStreak) { _, streak in
            withAnimation(.spring(response: 0.5)) { showFlower = streak > 0 }
        }
    }

    // MARK: - Rows

    private var mainRow: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("habit".uppercased())
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.cataMuted)
                    .kerning(2)
                Text(habit.title)
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .foregroundStyle(Color.cataInk)
                HStack(spacing: 4) {
                    Text("\(habit.currentStreak)")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.cataTerra)
                        .contentTransition(.numericText())
                    Text(habit.currentStreak == 1 ? "day" : "days")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(Color.cataMuted)
                }
            }
            Spacer()
            checkCircle
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }

    private var checkCircle: some View {
        Button { toggle() } label: {
            ZStack {
                Circle()
                    .stroke(habit.isCompletedToday() ? Color.cataTerra : Color.cataSand, lineWidth: 1.5)
                    .frame(width: 28, height: 28)
                if habit.isCompletedToday() {
                    Circle()
                        .fill(Color.cataTerra)
                        .frame(width: 28, height: 28)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .scaleEffect(checkBounce ? 1.25 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.45), value: checkBounce)
        }
        .buttonStyle(.plain)
    }

    private var flowerRow: some View {
        HStack {
            Spacer()
            FlowerView(streak: habit.currentStreak)
                .frame(width: 100, height: 130)
            Spacer()
        }
        .padding(.bottom, 16)
    }

    // MARK: - Logic

    private func toggle() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let wasCompleted = habit.isCompletedToday()

        if let existing = habit.entries.first(where: { cal.startOfDay(for: $0.date) == today }) {
            existing.completed.toggle()
        } else {
            let entry = HabitEntry(date: Date(), completed: true)
            entry.habit = habit
            habit.entries.append(entry)
            context.insert(entry)
        }

        if !wasCompleted {
            // Just completed — trigger burst + bounce
            checkBounce = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { checkBounce = false }
            burst = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { burst = false }
        }

        NotificationManager.shared.updateNudgesIfNeeded(habit: habit)
    }
}

// MARK: - Petal Burst

private struct PetalBurst: View {
    @State private var particles: [Particle] = Particle.generate()

    struct Particle: Identifiable {
        let id = UUID()
        let angle: Double       // direction to fly
        let distance: CGFloat
        let size: CGFloat
        let rotationStart: Double
        let rotationEnd: Double
        var offset: CGSize = .zero
        var opacity: Double = 0

        static func generate() -> [Particle] {
            (0..<12).map { i in
                let angle = Double(i) * 30.0 + Double.random(in: -15...15)
                return Particle(
                    angle: angle,
                    distance: CGFloat.random(in: 40...90),
                    size: CGFloat.random(in: 7...13),
                    rotationStart: Double.random(in: -30...30),
                    rotationEnd: Double.random(in: 60...180)
                )
            }
        }
    }

    var body: some View {
        ZStack {
            ForEach(particles) { p in
                CherryPetal()
                    .fill(LinearGradient(
                        colors: [Color.blossomWhite, Color.blossomPink],
                        startPoint: .top, endPoint: .bottom
                    ))
                    .frame(width: p.size, height: p.size * 1.5)
                    .rotationEffect(.degrees(p.rotationStart))
                    .offset(p.offset)
                    .opacity(p.opacity)
            }
        }
        .onAppear {
            for i in particles.indices {
                let rad = particles[i].angle * .pi / 180
                let dx = cos(rad) * particles[i].distance
                let dy = sin(rad) * particles[i].distance
                withAnimation(.easeOut(duration: 0.9).delay(Double(i) * 0.03)) {
                    particles[i].offset = CGSize(width: dx, height: -abs(dy))
                    particles[i].opacity = 0.9
                }
                withAnimation(.easeIn(duration: 0.4).delay(0.6)) {
                    particles[i].opacity = 0
                }
            }
        }
    }
}
