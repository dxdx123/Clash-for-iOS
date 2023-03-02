import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let dat = UTType(filenameExtension: "dat")!
}

struct MGGEOAssetView: View {
    
    var body: some View {
        NavigationLink {
            MGGEOAssetSettingView()
        } label: {
            Label {
                Text("GEO 资源")
            } icon: {
                Image(systemName: "cylinder.split.1x2")
            }
        }
    }
}

struct MGGEOAssetSettingView: View {
    
    @StateObject private var viewModel = MGGEOAssetViewModel()
    
    @State private var isFileImporterPresented: Bool = false
    
    var body: some View {
        Form {
            ForEach(viewModel.items) { item in
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.url.lastPathComponent)
                    Text(item.date.formatted())
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .fontWeight(.light)
                        .monospacedDigit()
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button("删除", role: .destructive) {
                        do {
                            try viewModel.delete(item: item)
                        } catch {
                            debugPrint(error.localizedDescription)
                        }
                    }
                }
            }
        }
        .navigationTitle(Text("GEO 资源"))
        .onAppear {
            viewModel.reload()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isFileImporterPresented.toggle()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
            }
        }
        .fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: [.dat], allowsMultipleSelection: true) { result in
            do {
                try viewModel.importLocalFiles(urls: try result.get())
                MGNotification.send(title: "", subtitle: "", body: "GEO资源导入成功")
            } catch {
                MGNotification.send(title: "", subtitle: "", body: "GEO资源导入失败, 原因: \(error.localizedDescription)")
            }
        }
    }
}
