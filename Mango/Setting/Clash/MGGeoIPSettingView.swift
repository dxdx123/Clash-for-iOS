import SwiftUI

extension MGConstant.Clash {
    static let defaultGeoIPDatabaseRemoteURLString  = "https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb"
    static let geoipDatabaseRemoteURLString         = "CLASH_GEOIP_DATABASE_REMOTE_URL_STRING"
    static let geoipDatabaseAutoUpdate              = "CLASH_GEOIP_DATABASE_AUTO_UPDATE"
}

struct MGGeoIPSettingView: View {
    
    @EnvironmentObject private var geoipManager: MGGEOIPManager
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage(MGConstant.Clash.geoipDatabaseRemoteURLString) private var geoipDatabaseRemoteURLString: String = MGConstant.Clash.defaultGeoIPDatabaseRemoteURLString
    @AppStorage(MGConstant.Clash.geoipDatabaseAutoUpdate) private var geoipDatabaseAutoUpdate: Bool = true
    
    @State private var isFileImporterPresented: Bool = false
    
    var body: some View {
        Form {
            Section {
                LabeledContent {
                    TextField("URL", text: $geoipDatabaseRemoteURLString)
                } label: {
                    Text("地址")
                }
                Toggle("自动更新", isOn: $geoipDatabaseAutoUpdate)
            }
            .disabled(geoipManager.isUpdating)
            
            Section {
                Button {
                    guard let url = URL(string: geoipDatabaseRemoteURLString) else {
                        return
                    }
                    Task(priority: .medium) {
                        do {
                            try await geoipManager.update(url: url)
                            MGNotification.send(title: "", subtitle: "", body: "GEOIP数据库更新成功")
                        } catch {
                            MGNotification.send(title: "", subtitle: "", body: "GEOIP数据库更新失败, 原因: \(error.localizedDescription)")
                        }
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text(geoipManager.isUpdating ? "正在更新" : "立即更新")
                        Spacer()
                    }
                }
            }
            .disabled(geoipManager.isUpdating)
        }
        .formStyle(.grouped)
        .navigationTitle(Text("GEOIP 数据库"))
        .toolbar {
            if geoipManager.isUpdating {
                ProgressView()
            } else {
                Button {
                    isFileImporterPresented.toggle()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
            }
        }
        .fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: [.mmdb]) { result in
            do {
                try geoipManager.importLocalFile(from: try result.get())
                MGNotification.send(title: "", subtitle: "", body: "GEOIP数据库导入成功")
            } catch {
                MGNotification.send(title: "", subtitle: "", body: "GEOIP数据库导入失败, 原因: \(error.localizedDescription)")
            }
        }
    }
}
