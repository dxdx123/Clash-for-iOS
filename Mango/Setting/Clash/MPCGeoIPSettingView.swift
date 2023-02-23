import SwiftUI
import UniformTypeIdentifiers

enum MGGEOIPAutoUpdateInterval: String, CaseIterable, Identifiable {
    
    var id: Self { self }
    
    case day
    case week
    case month
}

extension UTType {
    static let mmdb = UTType(filenameExtension: "mmdb")!
}

extension MGConstant.Clash {
    static let defaultGeoIPDatabaseRemoteURLString  = "https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb"
    static let geoipDatabaseRemoteURLString         = "CLASH_GEOIP_DATABASE_REMOTE_URL_STRING"
    static let geoipDatabaseAutoUpdate              = "CLASH_GEOIP_DATABASE_AUTO_UPDATE"
    static let geoipDatabaseAutoUpdateInterval      = "CLASH_GEOIP_DATABASE_AUTO_UPDATE_INTERVAL"
}

struct MPCGeoIPSettingView: View {
    
    @EnvironmentObject private var geoipManager: MPCGEOIPManager
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage(MGConstant.Clash.geoipDatabaseRemoteURLString) private var geoipDatabaseRemoteURLString: String = MGConstant.Clash.defaultGeoIPDatabaseRemoteURLString
    @AppStorage(MGConstant.Clash.geoipDatabaseAutoUpdate) private var geoipDatabaseAutoUpdate: Bool = true
    @AppStorage(MGConstant.Clash.geoipDatabaseAutoUpdateInterval) private var geoipDatabaseAutoUpdateInterval: MGGEOIPAutoUpdateInterval = .week
    
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
                if geoipDatabaseAutoUpdate {
                    NavigationLink {
                        MGFormPicker(title: "更新频率", selection: $geoipDatabaseAutoUpdateInterval) {
                            ForEach(MGGEOIPAutoUpdateInterval.allCases) { value in
                                Text(value.name)
                            }
                        }
                    } label: {
                        LabeledContent {
                            Text(geoipDatabaseAutoUpdateInterval.name)
                        } label: {
                            Text("更新频率")
                        }
                    }
                }
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
        .navigationTitle(Text("GeoIP 数据库"))
        .navigationBarTitleDisplayMode(.inline)
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

extension MGGEOIPAutoUpdateInterval {
    
    var name: String {
        switch self {
        case .day:
            return "每天"
        case .week:
            return "每周"
        case .month:
            return "每月"
        }
    }
}
