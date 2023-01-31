import SwiftUI
import NetworkExtension

struct CFIControlView: View {
    
    @EnvironmentObject private var manager: CFIPacketTunnelManager
    
    var body: some View {
        if let status = manager.status {
            switch status {
            case .connected, .disconnected:
                Button {
                    onTap(status: status)
                } label: {
                    Text(status.buttonTitle)
                }
            default:
                ProgressView()
            }
        } else {
            Button  {
                Task(priority: .high) {
                    do {
                        try await manager.saveToPreferences()
                    } catch {
                        debugPrint(error.localizedDescription)
                    }
                }
            } label: {
                Text("添加VPN配置")
            }
        }
    }
    
    private func buttonTitle(for status: NEVPNStatus) -> String {
        switch status {
        case .invalid:
            return "不可用"
        case .connecting:
            return "正在连接..."
        case .connected:
            return "断开"
        case .reasserting:
            return "正在重连..."
        case .disconnecting:
            return "正在断开..."
        case .disconnected:
            return "连接"
        @unknown default:
            return "未知"
        }
    }
    
    private func onTap(status: NEVPNStatus) {
        Task(priority: .high) {
            do {
                switch status {
                case .connected:
                    manager.stop()
                case .disconnected:
                    try await manager.start()
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
        case .invalid:
            return "不可用"
        case .connecting:
            return "正在连接..."
        case .connected:
            return "断开"
        case .reasserting:
            return "正在重连..."
        case .disconnecting:
            return "正在断开..."
        case .disconnected:
            return "连接"
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
