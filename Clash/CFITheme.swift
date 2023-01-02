import SwiftUI

enum CFITheme: String, CaseIterable, Identifiable {
    
    var id: Self { self }
    
    case light
    case dark
    case system
}

extension CFITheme {
    
    var preferredColorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}

extension CFIConstant {
    static let theme = "APP_PREFERRED_COLORSCHEME"
}
