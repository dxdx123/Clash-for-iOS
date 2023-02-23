import SwiftUI

struct MGContentView: View {
    
    @EnvironmentObject private var delegate: MGAppDelegate
    
    let kernel: Binding<MGKernel>
        
    var body: some View {
        MGHomeView(kernel: kernel)
    }
}
