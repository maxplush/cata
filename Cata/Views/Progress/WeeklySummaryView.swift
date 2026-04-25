import SwiftUI

struct WeeklySummaryView: View {
    let habit: Habit
    let checkIns: [DailyCheckIn]

    private var weekStart: Date {
        Calendar.current.date(from:
            Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        )!
    }

    private var thisWeekCheckIns: [DailyCheckIn] {
        checkIns.filter { $0.date >= weekStart }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This week")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.cataInk)

            weekDots

            if !thisWeekCheckIns.isEmpty {
                Divider().background(Color.cataSand.opacity(0.4))
                intentionsList
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.cataCard))
    }

    private var weekDots: some View {
        HStack(spacing: 5) {
            ForEach(0..<7) { i in
                let cal = Calendar.current
                let day = cal.date(byAdding: .day, value: i, to: weekStart)!
                let done = habit.isCompleted(on: day)
                let future = day > Date()
                let today = cal.isDateInToday(day)

                VStack(spacing: 5) {
                    Text(day.formatted(.dateTime.weekday(.narrow)))
                        .font(.system(size: 11))
                        .foregroundStyle(today ? Color.cataTerra : Color.cataMuted)

                    ZStack {
                        Circle()
                            .fill(done ? Color.cataTerra : future ? Color.cataSand.opacity(0.15) : Color.cataSand.opacity(0.38))
                            .frame(width: 36, height: 36)
                        if done {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var intentionsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Intentions this week")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.cataMuted)
                .textCase(.uppercase)
                .kerning(1)

            ForEach(thisWeekCheckIns.prefix(4)) { checkIn in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(Color.cataTerra.opacity(0.45))
                        .frame(width: 5, height: 5)
                        .padding(.top, 6)
                    Text(checkIn.accomplishment)
                        .font(.system(size: 14, design: .serif))
                        .foregroundStyle(Color.cataInk)
                        .lineSpacing(3)
                }
            }
        }
    }
}
