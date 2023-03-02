import SwiftUI

struct MGSniffingEntranceView: View {
    
    @AppStorage(MGConstant.Xray.sniffingEnable, store: .shared) private var enable: Bool = false
    
    var body: some View {
        NavigationLink {
            MGSniffingSettingView()
        } label: {
            LabeledContent {
                Text(enable ? "打开" : "关闭")
            } label: {
                Label("流量探测", systemImage: "magnifyingglass")
            }
        }
    }
}

struct MGSniffingSettingView: View {
    
    @AppStorage(MGConstant.Xray.sniffingEnable, store: .shared)                 private var enable: Bool                = false
    @AppStorage(MGConstant.Xray.sniffingDestOverrideHTTP, store: .shared)       private var destOverrideHTTP: Bool      = false
    @AppStorage(MGConstant.Xray.sniffingDestOverrideTLS, store: .shared)        private var destOverrideTLS: Bool       = false
    @AppStorage(MGConstant.Xray.sniffingDestOverrideQUIC, store: .shared)       private var destOverrideQUIC: Bool      = false
    @AppStorage(MGConstant.Xray.sniffingDestOverrideFAKEDNS, store: .shared)    private var destOverrideFAKEDNS: Bool   = false
    
    var body: some View {
        Form {
            Section {
                Toggle("启用", isOn: $enable)
            } header: {
                Text("状态")
            }
            Section {
                Toggle("HTTP",      isOn: $destOverrideHTTP)
                Toggle("TLS",       isOn: $destOverrideTLS)
                Toggle("QUIC",      isOn: $destOverrideQUIC)
                Toggle("FAKEDNS",   isOn: $destOverrideFAKEDNS)
            } header: {
                Text("流量类型")
            }
            .disabled(!enable)
        }
        .navigationTitle(Text("流量探测"))
    }
}
