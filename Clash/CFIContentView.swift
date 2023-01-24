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
                        Label {
                            Text("订阅")
                        } icon: {
                            CFIIcon(systemName: "doc.plaintext", backgroundColor: .green)
                        }
                    }
                }
                Section {
                    LabeledContent {
                        CFIControlView()
                    } label: {
                        Label {
                            Text("状态")
                        } icon: {
                            CFIIcon(systemName: "link", backgroundColor: .blue)
                        }
                    }
                    LabeledContent {
                        if let status = manager.status, status == .connected {
                            CFIConnectedDurationView()
                        }
                    } label: {
                        Label {
                            Text("连接时长")
                        } icon: {
                            CFIIcon(systemName: "clock", backgroundColor: .indigo)
                        }
                    }
                }
                Section {
                    NavigationLink {
                        CFITunnelModeView(tunnelMode: $tunnelMode)
                    } label: {
                        LabeledContent {
                            Text(tunnelMode.name)
                        } label: {
                            Label {
                                Text("代理模式")
                            } icon: {
                                CFIIcon(systemName: "arrow.uturn.right", backgroundColor: .orange)
                            }
                        }
                    }
                    LabeledContent {
                        CFIPolicyGroupView(tunnelMode: tunnelMode)
                    } label: {
                        Label {
                            Text("策略组")
                        } icon: {
                            CFIIcon(systemName: "square.3.layers.3d", backgroundColor: .purple)
                        }
                    }
                }
                Section {
                    NavigationLink {
                        CFISettingView()
                    } label: {
                        Label {
                            Text("设置")
                        } icon: {
                            CFIIcon(systemName: "gearshape", backgroundColor: .blue)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(Text("Clash"))
            .onChange(of: tunnelMode) { newValue in
                manager.set(tunnelMode: newValue)
            }
            .onChange(of: current) { newValue in
                manager.set(subscribe: newValue)
            }
        }
    }
}

