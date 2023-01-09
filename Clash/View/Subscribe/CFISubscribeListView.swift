import SwiftUI
import SPIndicator

struct CFISubscribeListView: View {
        
    @EnvironmentObject private var packetTunnelManager: CFIPacketTunnelManager
    @EnvironmentObject private var subscribeManager: CFISubscribeManager
    
    @State private var isDownloading = false
            
    let current: Binding<String>
    
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
                            SPIndicatorView(title: "删除成功", preset: .done)
                                .present(duration: 1.0)
                        } catch {
                            SPIndicatorView(title: "删除失败", message: error.localizedDescription, preset: .error)
                                .present(duration: 3.0)
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
                                SPIndicatorView(title: "更新订阅成功", preset: .done)
                                    .present(duration: 1.0)
                            } catch {
                                SPIndicatorView(title: "更新订阅失败", message: error.localizedDescription, preset: .error)
                                    .present(duration: 3.0)
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
                        SPIndicatorView(title: "重命名失败", message: error.localizedDescription, preset: .error)
                            .present(duration: 3.0)
                    }
                }
                Button("取消", role: .cancel) {}
            }
            .alert("订阅", isPresented: $isDownloadAlertPresented) {
                TextField("请输入订阅地址", text: $subscribeURLString)
                Button("确定") {
                    guard let source = URL(string: subscribeURLString) else {
                        return SPIndicatorView(title: "订阅失败", message: "不支持的URL", preset: .error)
                            .present(duration: 3.0)
                    }
                    isDownloading = true
                    Task(priority: .high) {
                        do {
                            try await subscribeManager.download(source: source)
                            await MainActor.run {
                                isDownloading = false
                                SPIndicatorView(title: "订阅成功", preset: .done)
                                    .present(duration: 1.0)
                            }
                        } catch {
                            await MainActor.run {
                                isDownloading = false
                                SPIndicatorView(title: "订阅失败", message: error.localizedDescription, preset: .error)
                                    .present(duration: 3.0)
                            }
                        }
                    }
                }
                Button("取消", role: .cancel) {}
            }
        }
    }
}
