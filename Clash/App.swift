import SwiftUI

@main
struct MPApp: App {
    
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
    
    @AppStorage(MPConstant.kernel) private var kernel = MPKernel.clash

    var body: some View {
        NavigationStack {
            Group {
                switch kernel {
                case .clash:
                    MPClashContentView()
                case .xray:
                    MPXrayContentView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker(selection: $kernel) {
                        ForEach(MPKernel.allCases) { kernel in
                            Text(kernel.rawValue.uppercased())
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
