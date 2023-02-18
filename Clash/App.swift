import SwiftUI

@main
struct CFIApp: App {
    
    @UIApplicationDelegateAdaptor private var delegate: AppDelegate
        
    @AppStorage(CFIConstant.accentColor) private var accentColor = CFIAccentColor.system
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(accentColor.tint)
        }
    }
}

struct ContentView: View {
    
    @AppStorage(CFIConstant.core) private var core = Core.clash

    var body: some View {
        NavigationStack {
            Group {
                switch core {
                case .clash:
                    ClashContentView(core: $core)
                case .xray:
                    XrayContentView(core: $core)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker(selection: $core) {
                        ForEach(Core.allCases) { core in
                            Text(core.rawValue.uppercased())
                        }
                    } label: {
                        EmptyView()
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
            }
        }
    }
}
