import SwiftUI
import NetworkExtension

struct MGControlView: View {
    
    @EnvironmentObject private var packetTunnelManager: MGPacketTunnelManager
    
    var body: some View {
        LabeledContent {
            if let status = packetTunnelManager.status {
                switch status {
                case .connected, .disconnected:
                    Button {
                        onTap(status: status)
                    } label: {
                        Text(status.buttonTitle)
                    }
                    .disabled(status == .invalid)
                default:
                    ProgressView()
                }
            } else {
                Button  {
                    Task(priority: .high) {
                        do {
                            try await packetTunnelManager.saveToPreferences()
                        } catch {
                            debugPrint(error.localizedDescription)
                        }
                    }
                } label: {
                    Text("安装")
                }
            }
        } label: {
            Label {
                Text(packetTunnelManager.status.flatMap({ $0.displayString }) ?? "未安装VPN配置")
            } icon: {
                Image(systemName: "link")
            }
        }
    }
    
    private func onTap(status: NEVPNStatus) {
        Task(priority: .high) {
            do {
                switch status {
                case .connected:
                    packetTunnelManager.stop()
                case .disconnected:
                    try await packetTunnelManager.start()
                default:
                    break
                }
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}

extension NEVPNStatus {
    
    var buttonTitle: String {
        switch self {
        case .invalid, .disconnected:
            return "连接"
        case .connected:
            return "断开"
        case .connecting, .reasserting, .disconnecting:
            return ""
        @unknown default:
            return "未知"
        }
    }
    
    var displayString: String {
        switch self {
        case .invalid:
            return "不可用"
        case .disconnected:
            return "未连接"
        case .connecting:
            return "正在连接..."
        case .connected:
            return "已连接"
        case .reasserting:
            return "正在重新连接..."
        case .disconnecting:
            return "正在断开连接..."
        @unknown default:
            return "未知"
        }
    }
}
