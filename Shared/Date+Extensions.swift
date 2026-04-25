import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    func weeksLived(birthYear: Int) -> Int {
        let birth = Calendar.current.date(
            from: DateComponents(year: birthYear, month: 1, day: 1)
        )!
        return max(0,
            Calendar.current
                .dateComponents([.weekOfYear], from: birth, to: self)
                .weekOfYear ?? 0
        )
    }
}
