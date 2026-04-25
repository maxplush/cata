import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var habits: [Habit]
    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]
    @Environment(\.modelContext) private var context
    @State private var showCheckIn = false
    @State private var showHabitSetup = false

    private var activeHabit: Habit? { habits.first(where: \.isActive) }
    private var checkedInToday: Bool { checkIns.first?.date.isToday == true }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cataBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        dateHeader
                            .padding(.top, 16)

                        if !checkedInToday {
                            checkInCard
                        }

                        if let habit = activeHabit {
                            HabitTrackerView(habit: habit)
                        } else {
                            habitSetupCard
                        }

                        if checkedInToday, let checkIn = checkIns.first {
                            todaysIntentionCard(checkIn)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCheckIn) {
                DailyCheckInView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showHabitSetup) {
                HabitSetupView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Subviews

    private var dateHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(Date().formatted(.dateTime.weekday(.wide)))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.cataMuted)
                    .textCase(.uppercase)
                    .kerning(1.2)
                Text(Date().formatted(.dateTime.month(.wide).day()))
                    .font(.system(size: 30, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.cataInk)
            }
            Spacer()
            Text("cata")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(Color.cataTerra)
                .padding(.top, 6)
        }
    }

    private var checkInCard: some View {
        Button { showCheckIn = true } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.cataTerra.opacity(0.12))
                        .frame(width: 50, height: 50)
                    Image(systemName: "sun.horizon.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.cataTerra)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Morning check-in")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.cataInk)
                    Text("Start your day with intention")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.cataMuted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.cataMuted.opacity(0.6))
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.cataCard))
        }
        .buttonStyle(.plain)
    }

    private var habitSetupCard: some View {
        Button { showHabitSetup = true } label: {
            VStack(spacing: 16) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.cataSage)
                VStack(spacing: 6) {
                    Text("Set your daily habit")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.cataInk)
                    Text("One small thing, done every day.")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.cataMuted)
                }
                Text("Get started")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.cataTerra)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.cataTerra.opacity(0.1)))
            }
            .frame(maxWidth: .infinity)
            .padding(32)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.cataCard))
        }
        .buttonStyle(.plain)
    }

    private func todaysIntentionCard(_ checkIn: DailyCheckIn) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today's intention")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.cataMuted)
                .textCase(.uppercase)
                .kerning(1.2)
            Text(checkIn.accomplishment)
                .font(.system(size: 16, design: .serif))
                .foregroundStyle(Color.cataInk)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.cataSage.opacity(0.12))
        )
    }
}
