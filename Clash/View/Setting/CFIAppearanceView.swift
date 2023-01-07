import SwiftUI

struct CFIAppearanceView: View {
    
    @AppStorage(CFIConstant.theme) private var theme = CFITheme.system
    
    var body: some View {
        NavigationLink {
            CFIFormPicker(title: "外观", selection: $theme) {
                ForEach(CFITheme.allCases) { theme in
                    Text(theme.name)
                }
            }
        } label: {
            LabeledContent {
                Text(theme.name)
            } label: {
                Label {
                    Text("外观")
                } icon: {
                    CFIIcon(systemName: "app.dashed", backgroundColor: .mint)
                }
            }
        }
    }
}

extension CFITheme {
    
    var name: String {
        switch self {
        case .light:
            return "浅色"
        case .dark:
            return "深色"
        case .system:
            return "系统"
        }
    }
}
