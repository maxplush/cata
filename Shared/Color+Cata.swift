import SwiftUI

extension Color {
    // Paper & Ink
    static let cataBg    = Color.white
    static let cataCard  = Color(hex: "F5F5F5")
    static let cataInk   = Color(hex: "1A1A1A")
    static let cataMuted = Color(hex: "999999")
    static let cataSand  = Color(hex: "DEDEDE")   // ruled lines

    // Single accent — hanko stamp red
    static let cataTerra = Color(hex: "B5272B")

    // Neutral mid-tone (replaces sage)
    static let cataSage  = Color(hex: "555555")

    // Cherry blossom (flower only)
    static let blossomPink  = Color(hex: "FFB7C5")
    static let blossomDeep  = Color(hex: "E0607E")
    static let blossomWhite = Color(hex: "FFF0F5")
    static let stemInk      = Color(hex: "2D4A2D")

    // Legacy aliases kept so widget compiles
    static let cataStem   = Color(hex: "2D4A2D")
    static let cataLeaf   = Color(hex: "3D6B3D")
    static let cataPetal  = Color(hex: "FFB7C5")
    static let cataPetalD = Color(hex: "E0607E")
    static let cataCenter = Color(hex: "FFE566")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}
