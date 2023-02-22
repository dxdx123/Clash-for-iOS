import SwiftUI

struct MGContentView: View {
    
    let kernel: Binding<MGKernel>
        
    var body: some View {
        NavigationStack {
            MGHomeView(kernel: kernel.wrappedValue)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Picker(selection: kernel) {
                            ForEach(MGKernel.allCases) { kernel in
                                Text(kernel.rawValue.uppercased())
                            }
                        } label: {
                            EmptyView()
                        }
                        .pickerStyle(.segmented)
                        .fixedSize()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        MGPresentedButton {
                            MGSettingView()
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                }
        }
    }
}
