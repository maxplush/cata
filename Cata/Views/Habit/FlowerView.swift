import SwiftUI

/// Cherry blossom that blossoms petal by petal as the streak grows.
/// Ink sketch style — monochrome until streak 7, then soft pink washes in.
struct FlowerView: View {
    let streak: Int

    @State private var petalAngles: [Double] = Array(repeating: 0, count: 8)
    @State private var petalScales: [CGFloat] = Array(repeating: 0, count: 8)
    @State private var stemHeight: CGFloat = 0
    @State private var colorSaturation: Double = 0
    @State private var sway: Double = 0

    private var petalCount: Int {
        switch streak {
        case 0:       return 0
        case 1...2:   return 1
        case 3...4:   return 2
        case 5...6:   return 3
        case 7...10:  return 5
        case 11...20: return 7
        default:      return 8
        }
    }

    private var targetStemHeight: CGFloat {
        switch streak {
        case 0:       return 0
        case 1...3:   return 30
        case 4...6:   return 50
        default:      return 65
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Stem
            stemView

            // Leaves
            if streak >= 3 {
                leafView(angle: -35, xOffset: -12, yOffset: -30)
                leafView(angle:  35, xOffset:  12, yOffset: -44)
            }

            // Petals
            ZStack {
                ForEach(0..<petalCount, id: \.self) { i in
                    CherryPetal()
                        .fill(petalFill(index: i))
                        .overlay(
                            CherryPetal()
                                .stroke(Color.cataInk.opacity(0.25), lineWidth: 0.5)
                        )
                        .frame(width: 18, height: 26)
                        .offset(y: -14)
                        .rotationEffect(.degrees(petalAngle(index: i, total: petalCount)))
                        .scaleEffect(petalScales[i])
                }

                // Center dot
                if petalCount > 0 {
                    Circle()
                        .fill(streak >= 7 ? Color(hex: "FFE566") : Color.cataInk.opacity(0.7))
                        .overlay(Circle().stroke(Color.cataInk.opacity(0.2), lineWidth: 0.5))
                        .frame(width: 8, height: 8)
                        .scaleEffect(petalScales[0])
                }
            }
            .offset(y: -(targetStemHeight + 14))
            .rotationEffect(.degrees(sway * 2.5), anchor: .bottom)
        }
        .frame(width: 100, height: 130)
        .onAppear { animate() }
        .onChange(of: streak) { animate() }
    }

    // MARK: - Subviews

    private var stemView: some View {
        Capsule()
            .fill(Color.stemInk.opacity(0.7))
            .frame(width: 1.5, height: stemHeight)
            .offset(y: -stemHeight / 2)
    }

    private func leafView(angle: Double, xOffset: CGFloat, yOffset: CGFloat) -> some View {
        Ellipse()
            .fill(Color.stemInk.opacity(0.5))
            .overlay(Ellipse().stroke(Color.stemInk.opacity(0.3), lineWidth: 0.5))
            .frame(width: 14, height: 8)
            .rotationEffect(.degrees(angle))
            .offset(x: xOffset, y: yOffset)
    }

    // MARK: - Helpers

    private func petalAngle(index: Int, total: Int) -> Double {
        guard total > 0 else { return 0 }
        return Double(index) * (360.0 / Double(total))
    }

    private func petalFill(index: Int) -> some ShapeStyle {
        if streak >= 7 {
            return AnyShapeStyle(LinearGradient(
                colors: [Color.blossomWhite, Color.blossomPink],
                startPoint: .top,
                endPoint: .bottom
            ))
        }
        return AnyShapeStyle(Color.cataInk.opacity(0.08))
    }

    private func animate() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
            stemHeight = targetStemHeight
        }
        for i in 0..<petalCount {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double(i) * 0.08)) {
                petalScales[i] = 1.0
            }
        }
        // Collapse petals that no longer exist
        for i in petalCount..<8 {
            petalScales[i] = 0
        }
        withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true).delay(0.5)) {
            sway = 1
        }
    }
}

// MARK: - Petal Shape

struct CherryPetal: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        let mx = w / 2

        // Start at the notched tip
        p.move(to: CGPoint(x: mx - 1.5, y: 0))
        p.addCurve(
            to: CGPoint(x: mx + 1.5, y: 0),
            control1: CGPoint(x: mx - 1.5, y: -3),
            control2: CGPoint(x: mx + 1.5, y: -3)
        )
        // Right side curve down to base
        p.addCurve(
            to: CGPoint(x: w, y: h * 0.65),
            control1: CGPoint(x: w * 1.1, y: h * 0.15),
            control2: CGPoint(x: w * 1.05, y: h * 0.45)
        )
        p.addCurve(
            to: CGPoint(x: mx, y: h),
            control1: CGPoint(x: w * 0.9, y: h * 0.85),
            control2: CGPoint(x: w * 0.65, y: h)
        )
        // Left side curve back up
        p.addCurve(
            to: CGPoint(x: 0, y: h * 0.65),
            control1: CGPoint(x: w * 0.35, y: h),
            control2: CGPoint(x: w * 0.1, y: h * 0.85)
        )
        p.addCurve(
            to: CGPoint(x: mx - 1.5, y: 0),
            control1: CGPoint(x: -w * 0.05, y: h * 0.45),
            control2: CGPoint(x: -w * 0.1, y: h * 0.15)
        )
        p.closeSubpath()
        return p
    }
}
