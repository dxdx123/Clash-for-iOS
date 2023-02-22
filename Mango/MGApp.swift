import SwiftUI

@main
struct MGApp: App {
    
    @AppStorage("MANGO_KERNEL", store: .shared) private var kernel = MGKernel.clash
    
    var body: some Scene {
        WindowGroup {
            MGContentView(kernel: $kernel)
        }
    }
}
