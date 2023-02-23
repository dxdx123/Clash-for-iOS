import SwiftUI
import NetworkExtension

//struct MPCContentView: View {
//        
//    @AppStorage(MGConstant.Clash.current, store: .shared) private var current = ""
//    
//    @StateObject private var packetTunnelManager    = MPPacketTunnelManager(kernel: .clash)
//    @StateObject private var subscribeManager       = MPCSubscribeManager()
//    @StateObject private var geoipManager           = MPCGEOIPManager()
//    
//    var body: some View {
//        Form {
//            Section {
////                MGSubscribeView(current: $current, packetTunnelManager: packetTunnelManager, subscribeManager: subscribeManager)
//            } header: {
//                Text("订阅")
//            }
//            Section {
////                MGControlView(packetTunnelManager: packetTunnelManager)
////                MGConnectedDurationView(packetTunnelManager: packetTunnelManager)
//            } header: {
//                Text("状态")
//            }
//            Section {
//                MPCPolicyGroupView(packetTunnelManager: packetTunnelManager)
//            } header: {
//                Text("代理")
//            }
//        }
//        .formStyle(.grouped)
//        .onChange(of: current) { newValue in
//            packetTunnelManager.set(subscribe: newValue)
//        }
//        .onAppear {
//            geoipManager.checkAndUpdateIfNeeded()
//        }
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                MPSettingButton {
//                    MPCSettingView(packetTunnelManager: packetTunnelManager, geoipManager: geoipManager)
//                }
//            }
//        }
//    }
//}
