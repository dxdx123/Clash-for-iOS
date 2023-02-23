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
                Text(Bundle.appVersion)
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .fontWeight(.light)
                    .monospacedDigit()
            }
        }
    }
}
