import SwiftUI

struct MGConfigurationView: View {
    
    @EnvironmentObject private var packetTunnelManager: MGPacketTunnelManager
    
    @EnvironmentObject private var configurationListManager: MGConfigurationListManager
    
    let current: Binding<String>
    
    var body: some View {
        Group {
            if configurationListManager.configurations.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.largeTitle)
                        Text("暂无配置")
                    }
                    .foregroundColor(.secondary)
                    .padding()
                    Spacer()
                }
            } else {
                ForEach(Array(configurationListManager.configurations.enumerated()), id: \.element.id) { pair in
                    Button {
                        guard current.wrappedValue != pair.element.id else {
                            return
                        }
                        current.wrappedValue = pair.element.id
                        guard let status = packetTunnelManager.status, status == .connected else {
                            return
                        }
                        packetTunnelManager.stop()
                        Task(priority: .userInitiated) {
                            do {
                                try await Task.sleep(for: .milliseconds(500))
                                try await packetTunnelManager.start()
                            } catch {}
                        }
                    } label: {
                        Label {
                            Text(pair.element.attributes.alias)
                                .lineLimit(1)
                        } icon: {
                            Text("\(pair.offset + 1)")
                                .lineLimit(1)
                                .monospacedDigit()
                        }
                        .foregroundColor(current.wrappedValue == pair.element.id ? .accentColor : .primary)
                    }
                }
            }
        }
        .onAppear {
            configurationListManager.reload()
        }
    }
    
    private var currentConfigurationName: String {
        guard let configuration = configurationListManager.configurations.first(where: { $0.id == current.wrappedValue }) else {
            return configurationListManager.configurations.isEmpty ? "无" : "未选择"
        }
        return configuration.attributes.alias
    }
}
