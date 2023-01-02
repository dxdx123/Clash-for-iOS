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
                    if let status = manager.status, status == .connected {
                        LabeledContent {
                            CFIConnectedDurationView()
                        } label: {
                            Label {
                                Text("连接时长")
                            } icon: {
                                CFIIcon(systemName: "clock", backgroundColor: .indigo)
                            }
                        }
                        NavigationLink {
                            CFIStatisticView(current: current)
                        } label: {
                            Label {
                                Text("统计")
                            } icon: {
                                CFIIcon(systemName: "bell.badge", backgroundColor: .red)
                            }
                        }
                    }
                }
                if manager.status == .connected {
                    Section {
                        LabeledContent {
                            CFIPolicyGroupView(tunnelMode: tunnelMode)
                        } label: {
                            Label {
                                Text("策略组")
                            } icon: {
                                CFIIcon(systemName: "square.grid.2x2", backgroundColor: .purple)
                            }
                        }
                    }
                }
                Section {
                    NavigationLink {
                        CFISettingView(tunnelMode: $tunnelMode)
                    } label: {
                        Label {
                            Text("设置")
                        } icon: {
                            CFIIcon(systemName: "gearshape", backgroundColor: .orange)
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

