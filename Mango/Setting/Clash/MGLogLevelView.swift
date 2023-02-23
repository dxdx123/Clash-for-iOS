import SwiftUI

struct MGLogLevelView: View {
    
    @EnvironmentObject private var packetTunnelManager: MGPacketTunnelManager
    @AppStorage(MGConstant.Clash.logLevel, store: .shared) private var logLevel  = MGLogLevel.silent
    
    var body: some View {
        NavigationLink {
            Form {
                Picker(selection: $logLevel) {
                    ForEach(MGLogLevel.allCases) { level in
                        Text(title(for: level))
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.inline)
            }
            .navigationTitle(Text("日志"))
        } label: {
            LabeledContent {
                Text(title(for: logLevel))
            } label: {
                Label {
                    Text("日志")
                } icon: {
                    Image(systemName: "doc.text.below.ecg")
                }
            }
        }
        .onChange(of: logLevel) { newValue in
            MGKernel.Clash.set(manager: packetTunnelManager, logLevel: newValue)
        }
    }
    
    private func title(for level: MGLogLevel) -> String {
        switch level {
        case .debug:
            return "调试"
        case .info:
            return "信息"
        case .warning:
            return "警告"
        case .error:
            return "错误"
        case .silent:
            return "静默"
        }
    }
}
