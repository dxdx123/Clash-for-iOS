import SwiftUI

enum CFIGEOIPAutoUpdateInterval: String, CaseIterable, Identifiable {
    
    var id: Self { self }
    
    case day
    case week
    case month
}

extension CFIConstant {
    static let defaultGEOIPDatabaseRemoteURLString  = "https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb"
    static let geoipDatabaseRemoteURLString         = "CLASH_GEOIP_DATABASE_REMOTE_URL_STRING"
    static let geoipDatabaseAutoUpdate              = "CLASH_GEOIP_DATABASE_AUTO_UPDATE"
    static let geoipDatabaseAutoUpdateInterval      = "CLASH_GEOIP_DATABASE_AUTO_UPDATE_INTERVAL"
}

struct CFIGEOIPSettingView: View {
    
    @EnvironmentObject private var geoipManager: CFIGEOIPManager
    
    @AppStorage(CFIConstant.geoipDatabaseRemoteURLString) private var geoipDatabaseRemoteURLString: String = CFIConstant.defaultGEOIPDatabaseRemoteURLString
    @AppStorage(CFIConstant.geoipDatabaseAutoUpdate) private var geoipDatabaseAutoUpdate: Bool = true
    @AppStorage(CFIConstant.geoipDatabaseAutoUpdateInterval) private var geoipDatabaseAutoUpdateInterval: CFIGEOIPAutoUpdateInterval = .week
    
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
                        Form {
                            Picker(selection: $geoipDatabaseAutoUpdateInterval) {
                                ForEach(CFIGEOIPAutoUpdateInterval.allCases) { interval in
                                    Text(title(for: interval))
                                }
                            } label: {
                                EmptyView()
                            }
                            .pickerStyle(.inline)
                        }
                        .formStyle(.grouped)
                        .navigationTitle(Text("更新频率"))
                        .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        LabeledContent {
                            Text(title(for: geoipDatabaseAutoUpdateInterval))
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
                        } catch {
                            debugPrint(error.localizedDescription)
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
        .navigationTitle(Text("GEOIP"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if geoipManager.isUpdating {
                ProgressView()
            }
        }
    }
    
    private func title(for interval: CFIGEOIPAutoUpdateInterval) -> String {
        switch interval {
        case .day:
            return "每天"
        case .week:
            return "每周"
        case .month:
            return "每月"
        }
    }
}
