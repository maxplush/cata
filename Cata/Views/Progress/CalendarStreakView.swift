import SwiftUI

struct CalendarStreakView: View {
    let habit: Habit
    @State private var displayMonth = Date()

    var body: some View {
        VStack(spacing: 12) {
            monthHeader
            dayLabels
            grid
        }
    }

    private var monthHeader: some View {
        HStack {
            Text(displayMonth.formatted(.dateTime.month(.wide).year()))
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.cataInk)
                .kerning(0.5)
            Spacer()
            HStack(spacing: 16) {
                Button { shiftMonth(-1) } label: {
                    Text("←").font(.system(size: 14)).foregroundStyle(Color.cataMuted)
                }
                Button { shiftMonth(1) } label: {
                    Text("→").font(.system(size: 14)).foregroundStyle(Color.cataMuted)
                }
                .disabled(Calendar.current.isDate(displayMonth, equalTo: Date(), toGranularity: .month))
            }
        }
    }

    private var dayLabels: some View {
        HStack {
            ForEach(["S","M","T","W","T","F","S"], id: \.self) { d in
                Text(d)
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.cataMuted)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var grid: some View {
        VStack(spacing: 4) {
            ForEach(weeks.indices, id: \.self) { wi in
                HStack(spacing: 4) {
                    ForEach(0..<7) { di in
                        if let date = weeks[wi][di] {
                            dayCell(for: date)
                        } else {
                            Color.clear.frame(maxWidth: .infinity).frame(height: 28)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func dayCell(for date: Date) -> some View {
        let cal = Calendar.current
        let completed = habit.isCompleted(on: date)
        let isToday   = cal.isDateInToday(date)
        let isFuture  = date > Date()
        let dayNum    = cal.component(.day, from: date)

        ZStack {
            if completed {
                Rectangle().fill(Color.cataInk)
            } else if isToday {
                Rectangle().stroke(Color.cataInk, lineWidth: 0.5)
            }
            Text("\(dayNum)")
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(
                    completed ? Color.cataBg
                    : isFuture ? Color.cataSand
                    : Color.cataInk
                )
        }
        .frame(maxWidth: .infinity)
        .frame(height: 28)
    }

    private var weeks: [[Date?]] {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.year, .month], from: displayMonth))!
        let range = cal.range(of: .day, in: .month, for: displayMonth)!
        let firstOffset = cal.component(.weekday, from: start) - 1
        var days: [Date?] = Array(repeating: nil, count: firstOffset)
        for d in range { days.append(cal.date(byAdding: .day, value: d - 1, to: start)) }
        while days.count % 7 != 0 { days.append(nil) }
        return stride(from: 0, to: days.count, by: 7).map { Array(days[$0..<$0+7]) }
    }

    private func shiftMonth(_ delta: Int) {
        guard let next = Calendar.current.date(byAdding: .month, value: delta, to: displayMonth) else { return }
        withAnimation(.spring(response: 0.3)) { displayMonth = next }
    }
}
