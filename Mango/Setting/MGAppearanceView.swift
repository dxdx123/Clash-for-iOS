import SwiftUI

struct MGAppearanceView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @AppStorage(MGConstant.theme) private var appearance = MGAppearance.system
    
    var body: some View {
        NavigationLink {
            MGFormPicker(title: "外观", selection: $appearance) {
                ForEach(MGAppearance.allCases) { appearance in
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
                    Image(systemName: "app.dashed")
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

extension MGAppearance {
    
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
