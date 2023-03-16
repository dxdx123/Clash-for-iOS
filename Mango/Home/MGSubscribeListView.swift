//import SwiftUI

//struct MGSubscribeListView: View {
//
//    @Environment(\.dismiss) private var dismiss
//
//    @EnvironmentObject private var tunnel: MGPacketTunnelManager
//    @EnvironmentObject private var subscribe: MGSubscribeManager
//
//    @State private var isDownloading = false
//
//    @State private var isDownloadAlertPresented: Bool = false
//    @State private var subscribeURLString: String = ""
//
//    @State private var isRenameAlertPresented = false
//    @State private var subscribeItem: MGSubscribe?
//    @State private var subscribeName: String = ""
//
//    let current: Binding<String>
//
//    init(current: Binding<String>) {
//        self.current = current
//    }
//
//    var body: some View {
//        NavigationStack {
//            List(subscribe.subscribes) { item in
//                Button {
//                    guard current.wrappedValue != item.id else {
//                        return
//                    }
//                    current.wrappedValue = item.id
//                    dismiss()
//                    guard let status = tunnel.status, status == .connected else {
//                        return
//                    }
//                    tunnel.stop()
//                    Task(priority: .userInitiated) {
//                        do {
//                            try await Task.sleep(for: .milliseconds(500))
//                            try await tunnel.start()
//                        } catch {}
//                    }
//                } label: {
//                    HStack(alignment: .center, spacing: 8) {
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text(item.extend.alias)
//                                .lineLimit(1)
//                                .foregroundColor(.primary)
//                                .fontWeight(.medium)
//                            Text(item.extend.leastUpdated.formatted(.relative(presentation: .named)))
//                                .lineLimit(1)
//                                .foregroundColor(.secondary)
//                                .font(.callout)
//                                .fontWeight(.light)
//                        }
//                        Spacer()
//                        if subscribe.downloadingSubscribeIDs.contains(item.id) {
//                            ProgressView()
//                        }
//                        if current.wrappedValue == item.id {
//                            Image(systemName: "checkmark")
//                                .foregroundColor(.accentColor)
//                                .fontWeight(.medium)
//                        }
//                    }
//                }
//                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
//                    Button("删除", role: .destructive) {
//                        do {
//                            try subscribe.delete(subscribe: item)
//                            if item.id == current.wrappedValue {
//                                current.wrappedValue = ""
//                            }
//                            MGNotification.send(title: "", subtitle: "", body: "\"\(item.extend.alias)\"删除成功")
//                        } catch {
//                            MGNotification.send(title: "", subtitle: "", body: "\"\(item.extend.alias)\"删除失败, 原因: \(error.localizedDescription)")
//                        }
//                    }
//                    .disabled(subscribe.downloadingSubscribeIDs.contains(item.id))
//
//                    Button("重命名") {
//                        self.subscribeName = item.extend.alias
//                        self.subscribeItem = item
//                        self.isRenameAlertPresented.toggle()
//                    }
//                    .tint(.yellow)
//                    .disabled(subscribe.downloadingSubscribeIDs.contains(item.id))
//
//                    Button("更新") {
//                        Task(priority: .userInitiated) {
//                            do {
//                                try await subscribe.update(subscribe: item)
//                                switch tunnel.kernel {
//                                case .clash:
//                                    if current.wrappedValue == item.id {
//                                        MGKernel.Clash.set(manager: tunnel, subscribe: item.id)
//                                    }
//                                case .xray:
//                                    break
//                                }
//                                MGNotification.send(title: "", subtitle: "", body: "\"\(item.extend.alias)\"更新成功")
//                            } catch {
//                                MGNotification.send(title: "", subtitle: "", body: "\"\(item.extend.alias)\"更新失败, 原因: \(error.localizedDescription)")
//                            }
//                        }
//                    }
//                    .tint(.green)
//                    .disabled(subscribe.downloadingSubscribeIDs.contains(item.id))
//                }
//            }
//            .navigationTitle(Text("配置管理"))
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                if isDownloading {
//                    ProgressView()
//                } else {
//                    Button {
//                        subscribeURLString = ""
//                        isDownloadAlertPresented.toggle()
//                    } label: {
//                        Image(systemName: "plus")
//                            .fontWeight(.medium)
//                    }
//                }
//            }
//            .alert("重命名", isPresented: $isRenameAlertPresented, presenting: subscribeItem) { item in
//                TextField("请输入配置名称", text: $subscribeName)
//                Button("确定") {
//                    let name = subscribeName.trimmingCharacters(in: .whitespacesAndNewlines)
//                    guard !(name == item.extend.alias || name.isEmpty) else {
//                        return
//                    }
//                    do {
//                        try subscribe.rename(subscribe: item, name: name)
//                    } catch {
//                        MGNotification.send(title: "", subtitle: "", body: "重命名失败, 原因: \(error.localizedDescription)")
//                    }
//                }
//                Button("取消", role: .cancel) {}
//            }
//            .alert("下载配置", isPresented: $isDownloadAlertPresented) {
//                TextField("请输入配置地址", text: $subscribeURLString)
//                Button("确定") {
//                    guard let source = URL(string: subscribeURLString) else {
//                        return MGNotification.send(title: "", subtitle: "", body: "下载失败, 原因: 不支持的URL")
//                    }
//                    isDownloading = true
//                    Task(priority: .high) {
//                        do {
//                            try await subscribe.download(source: source)
//                            await MainActor.run {
//                                isDownloading = false
//                                return MGNotification.send(title: "", subtitle: "", body: "下载成功")
//                            }
//                        } catch {
//                            await MainActor.run {
//                                isDownloading = false
//                                MGNotification.send(title: "", subtitle: "", body: "下载失败, 原因: \(error.localizedDescription)")
//                            }
//                        }
//                    }
//                }
//                Button("取消", role: .cancel) {}
//            }
//        }
//    }
//}
