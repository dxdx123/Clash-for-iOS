import SwiftUI

struct MGGEOIPView: View {
    
    @EnvironmentObject private var geoipManager: MGGEOIPManager
    
    var body: some View {
        NavigationLink {
            MGGeoIPSettingView()
                .environmentObject(geoipManager)
        } label: {
            LabeledContent {
                if geoipManager.isUpdating {
                    ProgressView()
                } else {
                    if let leastUpdated = geoipManager.leastUpdated {
                        Text(leastUpdated.formatted(date: .abbreviated, time: .shortened))
                    } else {
                        Text("无")
                    }
                }
            } label: {
                Label {
                    Text("GEOIP 数据库")
                } icon: {
                    Image(systemName: "cylinder.split.1x2")
                }
            }
        }
    }
}
