import SwiftUI

struct CFIContentView: View {
    
    @EnvironmentObject private var manager: CFIPacketTunnelManager
    
    @AppStorage(CFIConstant.tunnelMode, store: .shared) private var tunnelMode  = CFITunnelMode.rule
    @AppStorage(CFIConstant.current,    store: .shared) private var current     = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent {
                        CFISubscribeView(current: $current)
                    } label: {
                        Label("订阅", systemImage: "doc.plaintext")
                    }
                }
                Section {
                    LabeledContent {
                        CFIControlView()
                    } label: {
                        Label("状态", systemImage: "link")
                    }
                    if let status = manager.status, status == .connected {
                        LabeledContent {
                            CFIConnectedDurationView()
                        } label: {
                            Label("连接时长", systemImage: "clock")
                        }
                        NavigationLink {
                            CFIProviderListView(tunnelMode: tunnelMode)
                        } label: {
                            Label("策略组", systemImage: "square.grid.2x2")
                        }
                    }
                }
                Section {
                    NavigationLink {
                        CFISettingView(tunnelMode: $tunnelMode)
                    } label: {
                        Label("设置", systemImage: "gearshape")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(Text("主页"))
            .onChange(of: tunnelMode) { newValue in
                manager.set(tunnelMode: newValue)
            }
            .onChange(of: current) { newValue in
                manager.set(subscribe: newValue)
            }
        }
    }
}

