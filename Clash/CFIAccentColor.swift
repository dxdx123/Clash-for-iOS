import SwiftUI

enum CFIAccentColor: String, CaseIterable, Identifiable {
    
    var id: Self { self }
    
    case blue
    case red
    case orange
    case green
    case mint
    case teal
    case cyan
    case indigo
    case purple
    case pink
    case brown
    
}

extension CFIAccentColor {
    
    var name: String {
        switch self {
        case .blue:
            return "蓝"
        case .red:
            return "红"
        case .orange:
            return "橘黄"
        case .green:
            return "绿"
        case .mint:
            return "薄荷"
        case .teal:
            return "蓝绿"
        case .cyan:
            return "青"
        case .indigo:
            return "靛蓝"
        case .purple:
            return "紫"
        case .pink:
            return "粉红"
        case .brown:
            return "棕"
        }
    }
    
    var rawColor: Color {
        switch self {
        case .blue:
            return .blue
        case .red:
            return .red
        case .orange:
            return .orange
        case .green:
            return .green
        case .mint:
            return .mint
        case .teal:
            return .teal
        case .cyan:
            return .cyan
        case .indigo:
            return .indigo
        case .purple:
            return .purple
        case .pink:
            return .pink
        case .brown:
            return .brown
        }
    }
}

extension CFIConstant {
    static let accentColor = "APP_ACCENT_COLOR"
}
