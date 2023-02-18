import SwiftUI

struct CFISettingView: View {
    
    let core: Binding<Core>
    
    var body: some View {
        Form {
//            Section {
//                switch core.wrappedValue {
//                case .clash:
//                    CFILogLevelView()
//                    CFIGeoIPView()
//                        .environmentObject(CFIGEOIPManager())
//                    CFIIPV6View()
//                case .xray:
//                    EmptyView()
//                }
//            } header: {
//                Text("内核")
//            }
            Section {
                CFIAppearanceView()
                CFIAccentColorView()
            } header: {
                Text("主题")
            }
            Section {
                Picker(selection: core) {
                    ForEach(Core.allCases) { core in
                        Text(core.rawValue)
                    }
                } label: {
                    Text("内核")
                }
                .pickerStyle(.menu)
            }
//            Section {
//                CFIResetButton()
//            }
        }
        .formStyle(.grouped)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(Text("设置"))
        .safeAreaInset(edge: .bottom) {
            Text(version)
                .foregroundColor(.secondary)
                .font(.caption)
                .fontWeight(.light)
                .monospacedDigit()
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
