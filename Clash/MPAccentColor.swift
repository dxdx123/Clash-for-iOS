import SwiftUI

enum MPAccentColor: String, CaseIterable, Identifiable {
    
    var id: Self { self }
    
    case system
    case blue
    case purple
    case pink
    case red
    case orange
    case green
    case brown
}

extension MPAccentColor {
    
    var name: String {
        switch self {
        case .system:
            return "多色"
        case .blue:
            return "蓝色"
        case .red:
            return "红色"
        case .orange:
            return "橙色"
        case .green:
            return "绿色"
        case .purple:
            return "紫色"
        case .pink:
            return "粉色"
        case .brown:
            return "棕色"
        }
    }
    
    var tint: Color? {
        switch self {
        case .system:
            return nil
        case .blue:
            return .blue
        case .red:
            return .red
        case .orange:
            return .orange
        case .green:
            return .green
        case .purple:
            return .purple
        case .pink:
            return .pink
        case .brown:
            return .brown
        }
    }
}

extension MPConstant {
    static let accentColor = "APP_ACCENT_COLOR"
}
