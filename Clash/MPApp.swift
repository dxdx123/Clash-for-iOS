import SwiftUI

@main
struct MPApp: App {
    
    @UIApplicationDelegateAdaptor private var delegate: MPAppDelegate
    
    @AppStorage(MPConstant.kernel)          private var kernel      = MPKernel.clash
    @AppStorage(MPConstant.accentColor)    private var accentColor = MPAccentColor.system
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Group {
                    switch kernel {
                    case .clash:
                        MPClashContentView()
                            .tint(accentColor.tint)
                    case .xray:
                        MPXrayContentView()
                            .tint(accentColor.tint)
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
}
