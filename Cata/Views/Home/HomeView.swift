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
    private var quote: Quote { QuoteStore.today }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cataBg.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        pageHeader
                        rule
                        quoteSection
                        rule
                        habitSection
                        rule

                        if !checkedInToday {
                            checkInRow
                            rule
                        }

                        if checkedInToday, let checkIn = checkIns.first {
                            intentionRow(checkIn)
                            rule
                        }
                    }
                    .padding(.bottom, 60)
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

    // MARK: - Sections

    private var pageHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(Date().formatted(.dateTime.weekday(.wide)).uppercased())
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.cataMuted)
                .kerning(2)
            Spacer()
            Text(Date().formatted(.dateTime.month(.abbreviated).day().year()))
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.cataMuted)
                .kerning(1)
            Text("cata")
                .font(.system(size: 16, weight: .light, design: .serif))
                .foregroundStyle(Color.cataTerra)
                .kerning(3)
                .padding(.leading, 14)
        }
        .padding(.horizontal, 24)
        .padding(.top, 64)
        .padding(.bottom, 16)
    }

    private var quoteSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\u{201C}\(quote.text)\u{201D}")
                .font(.system(size: 15, weight: .light, design: .serif))
                .foregroundStyle(Color.cataInk)
                .lineSpacing(6)
                .italic()
            Text("— \(quote.author)")
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .foregroundStyle(Color.cataMuted)
                .kerning(0.5)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }

    private var habitSection: some View {
        Group {
            if let habit = activeHabit {
                VStack(spacing: 0) {
                    HabitTrackerView(habit: habit)
                    Button { showHabitSetup = true } label: {
                        HStack {
                            Text("change habit")
                                .font(.system(size: 10, weight: .regular, design: .monospaced))
                                .foregroundStyle(Color.cataMuted)
                                .kerning(1)
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                habitSetupRow
            }
        }
    }

    private var habitSetupRow: some View {
        Button { showHabitSetup = true } label: {
            HStack {
                Text("set your daily habit")
                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                    .foregroundStyle(Color.cataMuted)
                    .kerning(0.5)
                Spacer()
                Text("+")
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(Color.cataTerra)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .buttonStyle(.plain)
    }

    private var checkInRow: some View {
        Button { showCheckIn = true } label: {
            HStack {
                Text("morning check-in")
                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                    .foregroundStyle(Color.cataMuted)
                    .kerning(0.5)
                Spacer()
                Text("→")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.cataTerra)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .buttonStyle(.plain)
    }

    private func intentionRow(_ checkIn: DailyCheckIn) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("intention".uppercased())
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.cataMuted)
                .kerning(2)
            Text(checkIn.accomplishment)
                .font(.system(size: 15, design: .serif))
                .foregroundStyle(Color.cataInk)
                .lineSpacing(4)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }

    private var rule: some View {
        Rectangle()
            .fill(Color.cataSand)
            .frame(maxWidth: .infinity)
            .frame(height: 0.5)
            .padding(.horizontal, 24)
    }
}
