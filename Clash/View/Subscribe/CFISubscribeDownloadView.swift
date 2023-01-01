import SwiftUI

struct CFISubscribeDownloadView: View {
    
    @EnvironmentObject private var subscribeManager: CFISubscribeManager
    
    @StateObject private var downloader = CFISubscribeDownloader()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("名称") {
                    TextField("请输入订阅名称", text: $downloader.subscribeName)
                }
                Section("地址") {
                    TextField("请输入订阅地址", text: $downloader.subscribeURLString)
                }
                Section {
                    Button {
                        Task(priority: .userInitiated) {
                            guard await downloader.download() else {
                                return
                            }
                            await MainActor.run {
                                subscribeManager.reload()
                                dismiss()
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if downloader.isDownloading {
                                ProgressView()
                            } else {
                                Text("下载")
                                    .fontWeight(.medium)
                            }
                            Spacer()
                        }
                    }
                    .disabled(downloader.isDoneButtonDisable)
                }
            }
            .disabled(downloader.isDownloading)
            .navigationTitle(Text("添加订阅"))
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(downloader.isDownloading)
        }
    }
}
