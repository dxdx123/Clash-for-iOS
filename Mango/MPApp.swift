import SwiftUI

//@main
struct MPApp: App {
    
    @UIApplicationDelegateAdaptor private var delegate: MPAppDelegate
    
    @AppStorage(MGConstant.kernel) private var kernel = MPKernel.clash
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Group {
                    switch kernel {
                    case .clash:
                        MPCContentView()
                    case .xray:
                        MPXContentView()
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
