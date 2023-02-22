import SwiftUI

struct MGSettingView: View {
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    
                } header: {
                    Text("内核")
                }
                Section {
                    MGAppearanceView()
                } header: {
                    Text("主题")
                }
                Section {
                    
                }
            }
            .navigationTitle(Text("设置"))
            .safeAreaInset(edge: .bottom) {
                Text(version)
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .fontWeight(.light)
                    .monospacedDigit()
            }
        }
    }
    
    private var version: String {
        guard let info = Bundle.main.infoDictionary,
              let version = info["CFBundleShortVersionString"] as? String else {
            return "--"
        }
        return "版本: \(version)"
    }
}
