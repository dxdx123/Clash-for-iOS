import SwiftUI

struct CFILogLevelView: View {
    
    @EnvironmentObject private var manager: CFIPacketTunnelManager
    @AppStorage(CFIConstant.logLevel, store: .shared) private var logLevel  = CFILogLevel.silent
    
    var body: some View {
        NavigationLink {
            Form {
                Picker(selection: $logLevel) {
                    ForEach(CFILogLevel.allCases) { level in
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
                    CFIIcon(systemName: "doc.text.below.ecg", backgroundColor: .brown)
                }
            }
        }
        .onChange(of: logLevel) { newValue in
            manager.set(logLevel: newValue)
        }
    }
    
    private func title(for level: CFILogLevel) -> String {
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
