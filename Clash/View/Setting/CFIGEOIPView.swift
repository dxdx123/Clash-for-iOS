import SwiftUI

struct CFIGEOIPView: View {
    
    @EnvironmentObject private var geoipManager: CFIGEOIPManager
    
    var body: some View {
        NavigationLink {
            CFIGEOIPSettingView()
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
                    Text("GEOIP")
                } icon: {
                    CFIIcon(systemName: "cylinder.split.1x2", backgroundColor: .black)
                }
            }
        }
    }
}
