import SwiftUI

struct MGSettingView: View {
    
    @EnvironmentObject private var delegate: MGAppDelegate
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    
                } header: {
                    Text("内核")
                }
                Section {
                    MGResetView()
                        .environmentObject(delegate.packetTunnelManager)
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
