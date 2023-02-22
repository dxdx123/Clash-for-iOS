import SwiftUI

struct MPCLogLevelView: View {
    
    @StateObject private var packetTunnelManager: MPPacketTunnelManager
    @AppStorage(MGConstant.Clash.logLevel, store: .shared) private var logLevel  = MPCLogLevel.silent
    
    init(packetTunnelManager: MPPacketTunnelManager) {
        self._packetTunnelManager = StateObject(wrappedValue: packetTunnelManager)
    }
    
    var body: some View {
        NavigationLink {
            Form {
                Picker(selection: $logLevel) {
                    ForEach(MPCLogLevel.allCases) { level in
                        Text(title(for: level))
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.inline)
            }
            .navigationTitle(Text("日志"))
            .navigationBarTitleDisplayMode(.inline)
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
            packetTunnelManager.set(logLevel: newValue)
        }
    }
    
    private func title(for level: MPCLogLevel) -> String {
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
