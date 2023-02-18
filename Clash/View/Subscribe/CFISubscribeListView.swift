import SwiftUI

struct CFISubscribeListView: View {
    
    @Environment(\.dismiss) private var dismiss
        
    let current: Binding<String>
    @StateObject private var packetTunnelManager: MPPacketTunnelManager
    @StateObject private var subscribeManager: CFISubscribeManager
    
    init(current: Binding<String>, packetTunnelManager: MPPacketTunnelManager, subscribeManager: CFISubscribeManager) {
        self.current = current
        self._packetTunnelManager = StateObject(wrappedValue: packetTunnelManager)
        self._subscribeManager = StateObject(wrappedValue: subscribeManager)
    }
    
    @State private var isDownloading = false
            
    
    @State private var isDownloadAlertPresented: Bool = false
    @State private var subscribeURLString: String = ""
        
    @State private var isRenameAlertPresented = false
    @State private var subscribe: CFISubscribe?
    @State private var subscribeName: String = ""
    
    var body: some View {
        NavigationStack {
            List(subscribeManager.subscribes) { subscribe in
                Button {
                    guard current.wrappedValue != subscribe.id else {
                        return
                    }
                    current.wrappedValue = subscribe.id
                    dismiss()
                } label: {
                    HStack(alignment: .center, spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(subscribe.extend.alias)
                                .lineLimit(1)
                                .foregroundColor(.primary)
                                .fontWeight(.medium)
                            Text(subscribe.extend.leastUpdated.formatted(.relative(presentation: .named)))
                                .lineLimit(1)
                                .foregroundColor(.secondary)
                                .font(.callout)
                                .fontWeight(.light)
                        }
                        Spacer()
                        if subscribeManager.downloadingSubscribeIDs.contains(subscribe.id) {
                            ProgressView()
                        }
                        if current.wrappedValue == subscribe.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                                .fontWeight(.medium)
                        }
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button("删除", role: .destructive) {
                        do {
                            try subscribeManager.delete(subscribe: subscribe)
                            if subscribe.id == current.wrappedValue {
                                current.wrappedValue = ""
                            }
                            CFINotification.send(title: "", subtitle: "", body: "\"\(subscribe.extend.alias)\"删除成功")
                        } catch {
                            CFINotification.send(title: "", subtitle: "", body: "\"\(subscribe.extend.alias)\"删除失败, 原因: \(error.localizedDescription)")
                        }
                    }
                    .disabled(subscribeManager.downloadingSubscribeIDs.contains(subscribe.id))
                    
                    Button("重命名") {
                        self.subscribeName = subscribe.extend.alias
                        self.subscribe = subscribe
                        self.isRenameAlertPresented.toggle()
                    }
                    .tint(.yellow)
                    .disabled(subscribeManager.downloadingSubscribeIDs.contains(subscribe.id))
                    
                    Button("更新") {
                        Task(priority: .userInitiated) {
                            do {
                                try await subscribeManager.update(subscribe: subscribe)
                                if current.wrappedValue == subscribe.id {
                                    packetTunnelManager.set(subscribe: subscribe.id)
                                }
                                CFINotification.send(title: "", subtitle: "", body: "\"\(subscribe.extend.alias)\"更新成功")
                            } catch {
                                CFINotification.send(title: "", subtitle: "", body: "\"\(subscribe.extend.alias)\"更新失败, 原因: \(error.localizedDescription)")
                            }
                        }
                    }
                    .tint(.green)
                    .disabled(subscribeManager.downloadingSubscribeIDs.contains(subscribe.id))
                }
            }
            .navigationTitle(Text("订阅管理"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isDownloading {
                    ProgressView()
                } else {
                    Button {
                        subscribeURLString = ""
                        isDownloadAlertPresented.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.medium)
                    }
                }
            }
            .alert("重命名", isPresented: $isRenameAlertPresented, presenting: subscribe) { subscribe in
                TextField("请输入订阅名称", text: $subscribeName)
                Button("确定") {
                    let name = subscribeName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !(name == subscribe.extend.alias || name.isEmpty) else {
                        return
                    }
                    do {
                        try subscribeManager.rename(subscribe: subscribe, name: name)
                    } catch {
                        CFINotification.send(title: "", subtitle: "", body: "重命名失败, 原因: \(error.localizedDescription)")
                    }
                }
                Button("取消", role: .cancel) {}
            }
            .alert("订阅", isPresented: $isDownloadAlertPresented) {
                TextField("请输入订阅地址", text: $subscribeURLString)
                Button("确定") {
                    guard let source = URL(string: subscribeURLString) else {
                        return CFINotification.send(title: "", subtitle: "", body: "订阅失败, 原因: 不支持的URL")
                    }
                    isDownloading = true
                    Task(priority: .high) {
                        do {
                            try await subscribeManager.download(source: source)
                            await MainActor.run {
                                isDownloading = false
                                return CFINotification.send(title: "", subtitle: "", body: "订阅成功")
                            }
                        } catch {
                            await MainActor.run {
                                isDownloading = false
                                CFINotification.send(title: "", subtitle: "", body: "订阅失败, 原因: \(error.localizedDescription)")
                            }
                        }
                    }
                }
                Button("取消", role: .cancel) {}
            }
        }
    }
}
