import SwiftUI

struct MGConfigurationListView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var packetTunnelManager: MGPacketTunnelManager
    @EnvironmentObject private var configurationListManager: MGConfigurationListManager
    
    @State private var isDownloadViewPresented = false
    
    @State private var isRenameAlertPresented = false
    @State private var configurationItem: MGConfiguration?
    @State private var configurationName: String = ""
    
    let current: Binding<String>
    
    var body: some View {
        NavigationStack {
            List(configurationListManager.configurations) { configuration in
                HStack(alignment: .center, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(configuration.attributes.alias)
                            .lineLimit(1)
                            .foregroundColor(.primary)
                            .fontWeight(.medium)
                        Text(configuration.attributes.leastUpdated.formatted(.relative(presentation: .named)))
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                            .font(.callout)
                            .fontWeight(.light)
                    }
                    Spacer()
                    if configurationListManager.downloadingConfigurationIDs.contains(configuration.id) {
                        ProgressView()
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button("删除", role: .destructive) {
                        do {
                            try configurationListManager.delete(configuration: configuration)
                            if configuration.id == current.wrappedValue {
                                current.wrappedValue = ""
                            }
                            MGNotification.send(title: "", subtitle: "", body: "\"\(configuration.attributes.alias)\"删除成功")
                        } catch {
                            MGNotification.send(title: "", subtitle: "", body: "\"\(configuration.attributes.alias)\"删除失败, 原因: \(error.localizedDescription)")
                        }
                    }
                    .disabled(configurationListManager.downloadingConfigurationIDs.contains(configuration.id))
                    
                    Button("重命名") {
                        self.configurationName = configuration.attributes.alias
                        self.configurationItem = configuration
                        self.isRenameAlertPresented.toggle()
                    }
                    .tint(.yellow)
                    .disabled(configurationListManager.downloadingConfigurationIDs.contains(configuration.id))
                    
                    Button("更新") {
                        Task(priority: .userInitiated) {
                            do {
                                try await configurationListManager.update(configuration: configuration)
                                MGNotification.send(title: "", subtitle: "", body: "\"\(configuration.attributes.alias)\"更新成功")
                            } catch {
                                MGNotification.send(title: "", subtitle: "", body: "\"\(configuration.attributes.alias)\"更新失败, 原因: \(error.localizedDescription)")
                            }
                        }
                    }
                    .tint(.green)
                    .disabled(configuration.attributes.source.isFileURL || configurationListManager.downloadingConfigurationIDs.contains(configuration.id))
                }
            }
            .navigationTitle(Text("配置"))
            .navigationBarTitleDisplayMode(.large)
            .alert("重命名", isPresented: $isRenameAlertPresented, presenting: configurationItem) { item in
                TextField("请输入配置名称", text: $configurationName)
                Button("确定") {
                    let name = configurationName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !(name == item.attributes.alias || name.isEmpty) else {
                        return
                    }
                    do {
                        try configurationListManager.rename(configuration: item, name: name)
                    } catch {
                        MGNotification.send(title: "", subtitle: "", body: "重命名失败, 原因: \(error.localizedDescription)")
                    }
                }
                Button("取消", role: .cancel) {}
            }
            .toolbar {
                Button {
                    isDownloadViewPresented.toggle()
                } label: {
                    Image(systemName: "plus")
                        .fontWeight(.medium)
                }
            }
            .sheet(isPresented: $isDownloadViewPresented) {
                MGConfigurationLoadView()
            }
        }
    }
}
