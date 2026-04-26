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
            weekDots
            if !thisWeekCheckIns.isEmpty {
                Rectangle().fill(Color.cataSand).frame(height: 0.5)
                intentionsList
            }
        }
    }

    private var weekDots: some View {
        HStack(spacing: 4) {
            ForEach(0..<7) { i in
                let cal = Calendar.current
                let day = cal.date(byAdding: .day, value: i, to: weekStart)!
                let done = habit.isCompleted(on: day)
                let future = day > Date()
                let today = cal.isDateInToday(day)

                VStack(spacing: 5) {
                    Text(day.formatted(.dateTime.weekday(.narrow)))
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(today ? Color.cataTerra : Color.cataMuted)
                    ZStack {
                        Rectangle()
                            .fill(done ? Color.cataInk : Color.clear)
                            .overlay(Rectangle().stroke(
                                future ? Color.cataSand : Color.cataInk.opacity(0.3),
                                lineWidth: 0.5
                            ))
                            .frame(width: 28, height: 28)
                        if done {
                            Text("✓")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.cataBg)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var intentionsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(thisWeekCheckIns.prefix(4)) { checkIn in
                HStack(alignment: .top, spacing: 10) {
                    Text("—")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(Color.cataMuted)
                    Text(checkIn.accomplishment)
                        .font(.system(size: 13, design: .serif))
                        .foregroundStyle(Color.cataInk)
                        .lineSpacing(3)
                }
            }
        }
    }
}
