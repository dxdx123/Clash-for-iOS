import SwiftUI

struct MPCGeoIPView: View {
    
    @EnvironmentObject private var geoipManager: MPCGEOIPManager
    
    var body: some View {
        NavigationLink {
            MPCGeoIPSettingView()
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
                    Text("GeoIP 数据库")
                } icon: {
                    MPIcon(systemName: "cylinder.split.1x2", backgroundColor: .black)
                }
            }
        }
    }
}
