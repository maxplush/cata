import SwiftUI

/// Animated flower that grows more elaborate as the streak increases.
/// Stages: seed → sprout → bud → early bloom → full bloom → flourishing
struct FlowerView: View {
    let streak: Int

    @State private var appeared = false
    @State private var sway: Double = 0

    private var stage: Stage {
        switch streak {
        case 0:       return .seed
        case 1...2:   return .sprout
        case 3...6:   return .bud
        case 7...13:  return .earlyBloom
        case 14...29: return .fullBloom
        default:      return .flourishing
        }
    }

    enum Stage { case seed, sprout, bud, earlyBloom, fullBloom, flourishing }

    var body: some View {
        ZStack(alignment: .bottom) {
            stageView
        }
        .frame(width: 140, height: 180)
        .scaleEffect(appeared ? 1 : 0.4)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                sway = 1
            }
        }
        .onChange(of: streak) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.55)) {
                appeared = true
            }
        }
    }

    // MARK: - Stage routing

    @ViewBuilder
    private var stageView: some View {
        switch stage {
        case .seed:       seedView
        case .sprout:     sproutView
        case .bud:        budView
        case .earlyBloom: bloomView(petals: 5, flowerSize: 0.72)
        case .fullBloom:  bloomView(petals: 8, flowerSize: 1.0)
        case .flourishing: flourishingView
        }
    }

    // MARK: - Stages

    private var seedView: some View {
        Ellipse()
            .fill(Color(hex: "8B6347"))
            .frame(width: 14, height: 9)
            .offset(y: -6)
    }

    private var sproutView: some View {
        ZStack(alignment: .bottom) {
            stem(height: 48)
            leaf(angle: -28, x: -11, y: -18, w: 18, h: 10)
            leaf(angle:  28, x:  11, y: -28, w: 18, h: 10)
        }
    }

    private var budView: some View {
        ZStack(alignment: .bottom) {
            stem(height: 75)
            leaf(angle: -32, x: -14, y: -28, w: 26, h: 13)
            leaf(angle:  32, x:  14, y: -42, w: 26, h: 13)
            Ellipse()
                .fill(LinearGradient(
                    colors: [Color.cataPetal, Color.cataPetalD],
                    startPoint: .top, endPoint: .bottom
                ))
                .frame(width: 22, height: 34)
                .offset(y: -86)
        }
    }

    private func bloomView(petals: Int, flowerSize s: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            stem(height: 95 * s)
            leaf(angle: -34, x: -17 * s, y: -38 * s, w: 30 * s, h: 15 * s)
            leaf(angle:  34, x:  17 * s, y: -54 * s, w: 30 * s, h: 15 * s)

            flowerHead(petalCount: petals, size: s)
                .offset(y: -(108 * s))
                .rotationEffect(.degrees(sway * 3.5), anchor: .bottom)
        }
    }

    private var flourishingView: some View {
        ZStack(alignment: .bottom) {
            stem(height: 105)
            leaf(angle: -34, x: -18, y: -38, w: 32, h: 16)
            leaf(angle:  34, x:  18, y: -55, w: 32, h: 16)

            // main bloom
            flowerHead(petalCount: 10, size: 1.0)
                .overlay {
                    ForEach(0..<5, id: \.self) { i in
                        petal(size: 0.58)
                            .rotationEffect(.degrees(Double(i) * 72 + 18))
                    }
                }
                .offset(y: -116)
                .rotationEffect(.degrees(sway * 3), anchor: .bottom)

            // small accent flower
            miniFlower
                .offset(x: 32, y: -72)
        }
    }

    private var miniFlower: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { i in
                Ellipse()
                    .fill(Color.cataPetal.opacity(0.75))
                    .frame(width: 9, height: 16)
                    .offset(y: -9)
                    .rotationEffect(.degrees(Double(i) * 60))
            }
            Circle()
                .fill(Color.cataCenter.opacity(0.9))
                .frame(width: 9, height: 9)
        }
    }

    // MARK: - Helpers

    private func stem(height h: CGFloat) -> some View {
        Capsule()
            .fill(Color.cataStem)
            .frame(width: 3.5, height: h)
            .offset(y: -h / 2)
    }

    private func leaf(angle: Double, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) -> some View {
        Ellipse()
            .fill(Color.cataLeaf.opacity(0.85))
            .frame(width: w, height: h)
            .rotationEffect(.degrees(angle))
            .offset(x: x, y: y)
    }

    private func petal(size s: CGFloat) -> some View {
        Ellipse()
            .fill(LinearGradient(
                colors: [Color.cataPetal, Color.cataPetalD.opacity(0.7)],
                startPoint: .top, endPoint: .bottom
            ))
            .frame(width: 17 * s, height: 30 * s)
            .offset(y: -(15 * s))
    }

    private func flowerHead(petalCount: Int, size s: CGFloat) -> some View {
        ZStack {
            ForEach(0..<petalCount, id: \.self) { i in
                petal(size: s)
                    .rotationEffect(.degrees(Double(i) * (360.0 / Double(petalCount))))
            }
            Circle()
                .fill(Color.cataCenter)
                .frame(width: 17 * s, height: 17 * s)
                .shadow(color: .black.opacity(0.08), radius: 2)
        }
    }
}
