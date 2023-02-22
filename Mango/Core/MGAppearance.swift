import SwiftUI

enum MGAppearance: String, CaseIterable, Identifiable {
    
    var id: Self { self }
    
    case light
    case dark
    case system
}

extension MGAppearance {
    
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

extension MGConstant {
    static let theme = "APP_PREFERRED_COLORSCHEME"
}
