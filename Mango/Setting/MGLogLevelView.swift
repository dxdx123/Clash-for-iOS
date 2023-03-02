import SwiftUI

struct MGLogLevelView: View {
    
    @EnvironmentObject private var packetTunnelManager: MGPacketTunnelManager
    @AppStorage(MGConstant.logLevel, store: .shared) private var logLevel  = MGLogLevel.silent
    
    var body: some View {
        NavigationLink {
            MGFormPicker(title: "日志", selection: $logLevel) {
                ForEach(MGLogLevel.allCases) { level in
                    Text(title(for: level))
                }
            }
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
            guard let kernel = UserDefaults.shared.string(forKey: MGKernel.storeKey).flatMap(MGKernel.init(rawValue:)) else {
                return
            }
            switch kernel {
            case .clash:
                MGKernel.Clash.set(manager: packetTunnelManager, logLevel: newValue)
            case .xray:
                break
            }
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
            return "关闭"
        }
    }
}
