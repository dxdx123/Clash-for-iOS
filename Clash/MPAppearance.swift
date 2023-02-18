import SwiftUI

enum MPAppearance: String, CaseIterable, Identifiable {
    
    var id: Self { self }
    
    case light
    case dark
    case system
}

extension MPAppearance {
    
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return .unspecified
        }
    }
}

extension CFIConstant {
    static let theme = "APP_PREFERRED_COLORSCHEME"
}
