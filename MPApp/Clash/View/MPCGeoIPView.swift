import SwiftUI

struct MPCGeoIPView: View {
    
    @StateObject private var geoipManager: MPCGEOIPManager
    
    init(geoipManager: MPCGEOIPManager) {
        self._geoipManager = StateObject(wrappedValue: geoipManager)
    }
    
    var body: some View {
        NavigationLink {
            MPCGeoIPSettingView()
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
                    Text("GeoIP 数据库")
                } icon: {
                    Image(systemName: "cylinder.split.1x2")
                }
            }
        }
    }
}
