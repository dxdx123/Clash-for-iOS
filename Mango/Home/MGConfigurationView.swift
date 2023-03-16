import SwiftUI

struct MGConfigurationView: View {
    
    @EnvironmentObject private var packetTunnelManager: MGPacketTunnelManager
    
    @EnvironmentObject private var configurationListManager: MGConfigurationListManager
        
    @State private var isConfigurationListExpanded = true

    let current: Binding<String>
    
    var body: some View {
        DisclosureGroup(isExpanded: $isConfigurationListExpanded) {
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
                    .padding(.trailing, 25)
                    Spacer()
                }
            } else {
                ForEach(configurationListManager.configurations) { configuration in
                    Button {
                        guard current.wrappedValue != configuration.id else {
                            return
                        }
                        current.wrappedValue = configuration.id
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
                            HStack {
                                Text(configuration.attributes.alias)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                            }
                        } icon: {
                            Image(systemName: "arrow.right")
                                .opacity(current.wrappedValue == configuration.id ? 1.0 : 0.0)
                        }
                    }
                }
            }
        } label: {
            LabeledContent {
                Text(isConfigurationListExpanded ? "" : currentConfigurationName)
            } label: {
                Label {
                    Text("配置")
                } icon: {
                    Image(systemName: "doc.plaintext")
                }
            }
        }
        .listRowSeparator(configurationListManager.configurations.isEmpty ? .hidden : .automatic)
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
