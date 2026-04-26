import SwiftUI
import SwiftData

struct CheckInHistoryView: View {
    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.cataBg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                header
                thinRule

                if checkIns.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(checkIns) { checkIn in
                                checkInEntry(checkIn)
                                thinRule
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    private var header: some View {
        HStack {
            Text("Journal")
                .font(.system(size: 22, weight: .light, design: .serif))
                .foregroundStyle(Color.cataInk)
            Spacer()
            Button { dismiss() } label: {
                Text("✕")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.cataMuted)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .padding(.bottom, 20)
    }

    private func checkInEntry(_ checkIn: DailyCheckIn) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(checkIn.date.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.cataTerra)
                .kerning(1.5)

            entryRow(label: "GRATITUDE", text: checkIn.gratitude)
            entryRow(label: "INTENTION", text: checkIn.accomplishment)
            entryRow(label: "RELEASE",   text: checkIn.stopDoing)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }

    private func entryRow(label: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.cataMuted)
                .kerning(2)
            Text(text)
                .font(.system(size: 14, design: .serif))
                .foregroundStyle(Color.cataInk)
                .lineSpacing(4)
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No entries yet.")
                .font(.system(size: 15, design: .serif))
                .foregroundStyle(Color.cataMuted)
        }
        .padding(24)
    }

    private var thinRule: some View {
        Rectangle()
            .fill(Color.cataSand)
            .frame(maxWidth: .infinity)
            .frame(height: 0.5)
    }
}
