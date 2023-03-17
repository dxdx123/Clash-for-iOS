import SwiftUI

struct MGLogSettingView: View {
    
    @EnvironmentObject  private var packetTunnelManager: MGPacketTunnelManager
    @ObservedObject private var logViewModel: MGLogViewModel
    
    init(logViewModel: MGLogViewModel) {
        self._logViewModel = ObservedObject(initialValue: logViewModel)
    }
    
    var body: some View {
        Form {
            Section {
                Picker(selection: $logViewModel.errorLogSeverity) {
                    ForEach(MGLogModel.Severity.allCases) { severity in
                        Text(severity.displayTitle)
                    }
                } label: {
                    Text("错误日志")
                }
            }
            Section {
                Toggle("访问日志", isOn: $logViewModel.accessLogEnabled)
                Toggle("DNS 查询日志", isOn: $logViewModel.dnsLogEnabled)
            }
        }
        .navigationTitle(Text("日志"))
        .navigationBarTitleDisplayMode(.large)
        .onDisappear {
            self.logViewModel.save {
                guard let status = packetTunnelManager.status, status == .connected else {
                    return
                }
                packetTunnelManager.stop()
                Task(priority: .userInitiated) {
                    do {
                        try await Task.sleep(for: .milliseconds(500))
                        try await packetTunnelManager.start()
                    } catch {
                        debugPrint(error.localizedDescription)
                    }
                }
            }
        }
    }
}

extension MGLogModel.Severity {
    
    var displayTitle: String {
        switch self {
        case .none:
            return "关闭"
        case .error:
            return "错误"
        case .warning:
            return "警告"
        case .info:
            return "信息"
        case .debug:
            return "调试"
        }
    }
}
