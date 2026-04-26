import SwiftUI
import SwiftData

struct LifeInWeeksView: View {
    @Query private var profiles: [UserProfile]

    private let totalWeeks = 80 * 52
    private let columns = 52

    private var weeksLived: Int {
        guard let profile = profiles.first else { return 0 }
        return Date().weeksLived(birthYear: profile.birthYear)
    }

    private var weeksRemaining: Int { max(0, totalWeeks - weeksLived) }
    private var percentLived: Double { Double(weeksLived) / Double(totalWeeks) }

    private var rule: some View {
        Rectangle().fill(Color.cataSand).frame(maxWidth: .infinity).frame(height: 0.5)
            .padding(.horizontal, 24)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cataBg.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        headerSection
                        rule
                        gridSection
                        rule
                        reflectionSection
                    }
                    .padding(.bottom, 60)
                }
            }
            .navigationTitle("Life in Weeks")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(weeksLived)")
                    .font(.system(size: 48, weight: .light, design: .serif))
                    .foregroundStyle(Color.cataTerra)
                    .contentTransition(.numericText())
                Text("weeks lived")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(Color.cataMuted)
                    .offset(y: -6)
            }

            GeometryReader { geo in
                HStack(spacing: 0) {
                    Rectangle().fill(Color.cataInk).frame(width: geo.size.width * percentLived)
                    Rectangle().fill(Color.cataSand)
                }
                .frame(height: 1)
            }
            .frame(height: 1)

            Text("\(weeksRemaining) remaining · 80yr average")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(Color.cataMuted)
                .kerning(0.5)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }

    private var gridSection: some View {
        GeometryReader { geo in
            let available = geo.size.width - 48
            let gap: CGFloat = 1
            let cellSize = (available - gap * CGFloat(columns - 1)) / CGFloat(columns)
            let rows = totalWeeks / columns

            VStack(spacing: gap) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: gap) {
                        ForEach(0..<columns, id: \.self) { col in
                            let week = row * columns + col
                            Rectangle()
                                .fill(cellColor(week: week))
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
        }
        .frame(height: {
            let available = UIScreen.main.bounds.width - 48
            let gap: CGFloat = 1
            let cellSize = (available - gap * CGFloat(columns - 1)) / CGFloat(columns)
            let rows = CGFloat(totalWeeks / columns)
            return rows * cellSize + (rows - 1) * gap
        }())
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }

    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Each square is one week.")
                .font(.system(size: 15, design: .serif))
                .foregroundStyle(Color.cataInk)
            Text("Not morbid — clarifying.")
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(Color.cataMuted)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }

    private func cellColor(week: Int) -> Color {
        if week < weeksLived {
            let t = Double(week) / max(1, Double(weeksLived))
            return Color.cataInk.opacity(0.15 + t * 0.7)
        }
        if week == weeksLived { return Color.cataTerra }
        return Color.cataSand.opacity(0.4)
    }
}
