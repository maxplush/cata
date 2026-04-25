import SwiftUI
import SwiftData

struct LifeInWeeksView: View {
    @Query private var profiles: [UserProfile]

    private let totalWeeks = 80 * 52   // 4160
    private let columns = 52

    private var weeksLived: Int {
        guard let profile = profiles.first else { return 0 }
        return Date().weeksLived(birthYear: profile.birthYear)
    }

    private var weeksRemaining: Int { max(0, totalWeeks - weeksLived) }
    private var percentLived: Double { Double(weeksLived) / Double(totalWeeks) }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.cataBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        headerStats
                            .padding(.top, 4)
                        weekGrid
                        legend
                        reflectionCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Life in Weeks")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Subviews

    private var headerStats: some View {
        VStack(spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(weeksLived)")
                    .font(.system(size: 56, weight: .bold, design: .serif))
                    .foregroundStyle(Color.cataTerra)
                    .contentTransition(.numericText())
                Text("weeks lived")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.cataMuted)
                    .offset(y: -6)
            }

            GeometryReader { geo in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.cataTerra)
                        .frame(width: geo.size.width * percentLived)
                    Rectangle()
                        .fill(Color.cataSand.opacity(0.25))
                }
                .frame(height: 4)
                .clipShape(Capsule())
            }
            .frame(height: 4)

            Text("\(weeksRemaining) weeks ahead · based on 80 year average")
                .font(.system(size: 12))
                .foregroundStyle(Color.cataMuted)
        }
    }

    private var weekGrid: some View {
        GeometryReader { geo in
            let cellSize = (geo.size.width - CGFloat(columns - 1) * 1.5) / CGFloat(columns)
            let rows = totalWeeks / columns

            VStack(spacing: 1.5) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 1.5) {
                        ForEach(0..<columns, id: \.self) { col in
                            let week = row * columns + col
                            RoundedRectangle(cornerRadius: 1)
                                .fill(cellColor(week: week))
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
        }
        .frame(height: {
            let cellSize = (UIScreen.main.bounds.width - 40 - CGFloat(columns - 1) * 1.5) / CGFloat(columns)
            let rows = CGFloat(totalWeeks / columns)
            return rows * cellSize + (rows - 1) * 1.5
        }())
    }

    private var legend: some View {
        HStack(spacing: 20) {
            legendItem(color: Color.cataTerra.opacity(0.5), label: "Lived")
            legendItem(color: Color.cataTerra, label: "Now", dot: true)
            legendItem(color: Color.cataSand.opacity(0.25), label: "Ahead")
        }
        .frame(maxWidth: .infinity)
    }

    private func legendItem(color: Color, label: String, dot: Bool = false) -> some View {
        HStack(spacing: 6) {
            if dot {
                Circle().fill(color).frame(width: 9, height: 9)
            } else {
                RoundedRectangle(cornerRadius: 1).fill(color).frame(width: 9, height: 9)
            }
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(Color.cataMuted)
        }
    }

    private var reflectionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Each square is one week.")
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(Color.cataInk)
            Text("Not morbid — clarifying. Every week you spend with intention is a week well lived.")
                .font(.system(size: 14))
                .foregroundStyle(Color.cataMuted)
                .lineSpacing(4)
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.cataCard))
    }

    // MARK: - Helpers

    private func cellColor(week: Int) -> Color {
        if week < weeksLived {
            let progress = Double(week) / max(1, Double(weeksLived))
            return Color.cataTerra.opacity(0.25 + progress * 0.6)
        }
        if week == weeksLived { return Color.cataTerra }
        return Color.cataSand.opacity(0.2)
    }
}
