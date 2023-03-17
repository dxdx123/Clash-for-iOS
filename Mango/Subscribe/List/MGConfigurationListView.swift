import SwiftUI

struct MGConfigurationListView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var packetTunnelManager: MGPacketTunnelManager
    @EnvironmentObject private var configurationListManager: MGConfigurationListManager
        
    @State private var isRenameAlertPresented = false
    @State private var configurationItem: MGConfiguration?
    @State private var configurationName: String = ""
    
    @State private var location: MGConfigurationLocation?
    
    let current: Binding<String>
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        location = .remote
                    } label: {
                        Label("从 URL 下载", systemImage: "square.and.arrow.down.on.square")
                    }
                    Button {
                        location = .local
                    } label: {
                        Label("从文件夹导入", systemImage: "tray.and.arrow.down")
                    }
                } header: {
                    Text("导入")
                }
                Section {
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
                        ForEach(configurationListManager.configurations) { configuration in
                            HStack(alignment: .center, spacing: 8) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(configuration.attributes.alias)
                                        .lineLimit(1)
                                        .foregroundColor(.primary)
                                        .fontWeight(.medium)
                                    TimelineView(.periodic(from: Date(), by: 1)) { _ in
                                        Text(configuration.attributes.leastUpdated.formatted(.relative(presentation: .numeric)))
                                            .lineLimit(1)
                                            .foregroundColor(.secondary)
                                            .font(.callout)
                                            .fontWeight(.light)
                                    }
                                }
                                Spacer()
                                if configurationListManager.downloadingConfigurationIDs.contains(configuration.id) {
                                    ProgressView()
                                }
                            }
                            .contextMenu {
                                Button {
                                    self.configurationName = configuration.attributes.alias
                                    self.configurationItem = configuration
                                    self.isRenameAlertPresented.toggle()
                                } label: {
                                    Label("重命名", systemImage: "square.and.pencil")
                                }
                                Button {
                                    Task(priority: .userInitiated) {
                                        do {
                                            try await configurationListManager.update(configuration: configuration)
                                            MGNotification.send(title: "", subtitle: "", body: "\"\(configuration.attributes.alias)\"更新成功")
                                            if configuration.id == current.wrappedValue {
                                                guard let status = packetTunnelManager.status, status == .connected else {
                                                    return
                                                }
                                                packetTunnelManager.stop()
                                                do {
                                                    try await packetTunnelManager.start()
                                                } catch {
                                                    debugPrint(error.localizedDescription)
                                                }
                                            }
                                        } catch {
                                            MGNotification.send(title: "", subtitle: "", body: "\"\(configuration.attributes.alias)\"更新失败, 原因: \(error.localizedDescription)")
                                        }
                                    }
                                } label: {
                                    Label("更新", systemImage: "arrow.triangle.2.circlepath")
                                }
                                .disabled(configurationListManager.downloadingConfigurationIDs.contains(configuration.id) || configuration.attributes.source.isFileURL)
                                Divider()
                                Button(role: .destructive) {
                                    do {
                                        try configurationListManager.delete(configuration: configuration)
                                        MGNotification.send(title: "", subtitle: "", body: "\"\(configuration.attributes.alias)\"删除成功")
                                        if configuration.id == current.wrappedValue {
                                            current.wrappedValue = ""
                                            packetTunnelManager.stop()
                                        }
                                    } catch {
                                        MGNotification.send(title: "", subtitle: "", body: "\"\(configuration.attributes.alias)\"删除失败, 原因: \(error.localizedDescription)")
                                    }
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                                .disabled(configurationListManager.downloadingConfigurationIDs.contains(configuration.id))
                            }
                        }
                    }
                } header: {
                    Text("配置列表")
                } footer: {
                    Text("支持 JSON、YAML、TOML 格式配置")
                }
            }
            .navigationTitle(Text("配置管理"))
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
            .sheet(item: $location) { location in
                MGConfigurationLoadView(location: location)
            }
        }
    }
}
