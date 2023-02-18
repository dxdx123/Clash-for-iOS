import SwiftUI

struct CFIAppearanceView: View {
    
    @AppStorage(CFIConstant.theme) private var appearance = MPAppearance.system
    
    var body: some View {
        NavigationLink {
            CFIFormPicker(title: "外观", selection: $appearance) {
                ForEach(MPAppearance.allCases) { appearance in
                    Text(appearance.name)
                }
            }
        } label: {
            LabeledContent {
                Text(appearance.name)
            } label: {
                Label {
                    Text("外观")
                } icon: {
                    CFIIcon(systemName: "app.dashed", backgroundColor: .mint)
                }
            }
        }
        .onChange(of: appearance) { _ in
            Task(priority: .userInitiated) {
                do {
                    try await Task.sleep(for: .milliseconds(250))
                } catch {
                    debugPrint(error)
                }
                await MainActor.run {
                    UIApplication.shared.overrideUserInterfaceStyle()
                }
            }
        }
    }
}

extension MPAppearance {
    
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
