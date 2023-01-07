import SwiftUI

struct CFIAppearanceView: View {
    
    @AppStorage(CFIConstant.theme) private var theme = CFITheme.system
    
    var body: some View {
        NavigationLink {
            Form {
                Picker(selection: $theme) {
                    ForEach(CFITheme.allCases) { theme in
                        Text(title(for: theme))
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.inline)
            }
            .navigationTitle(Text("外观"))
            .navigationBarTitleDisplayMode(.inline)
        } label: {
            LabeledContent {
                Text(title(for: theme))
            } label: {
                Label {
                    Text("外观")
                } icon: {
                    CFIIcon(systemName: "app.dashed", backgroundColor: .mint)
                }
            }
        }
    }
    
    private func title(for theme: CFITheme) -> String {
        switch theme {
        case .light:
            return "浅色"
        case .dark:
            return "深色"
        case .system:
            return "系统"
        }
    }
}
