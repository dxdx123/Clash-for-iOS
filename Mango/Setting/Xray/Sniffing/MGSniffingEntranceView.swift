import SwiftUI

struct MGSniffingEntranceView: View {
        
    @StateObject private var sniffingViewModel = MGSniffingViewModel()
    
    var body: some View {
        NavigationLink {
            MGSniffingSettingView(sniffingViewModel: sniffingViewModel)
        } label: {
            LabeledContent {
                Text(sniffingViewModel.enabled ? "打开" : "关闭")
            } label: {
                Label("流量嗅探", systemImage: "magnifyingglass")
            }
        }
    }
}
