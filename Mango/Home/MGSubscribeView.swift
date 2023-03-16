//import SwiftUI

//struct MGSubscribeView: View {
//
//    let current: Binding<String>
//    @EnvironmentObject private var tunnel: MGPacketTunnelManager
//    @EnvironmentObject private var subscribe: MGSubscribeManager
//
//    init(current: Binding<String>) {
//        self.current = current
//    }
//
//    @State private var isPresented = false
//
//    var body: some View {
//        LabeledContent {
//            Button("切换") {
//                isPresented.toggle()
//            }
//            .sheet(isPresented: $isPresented) {
//                MGSubscribeListView(current: current)
//                    .presentationDetents([.medium, .large])
//                    .presentationDragIndicator(.hidden)
//            }
//        } label: {
//            Label {
//                Text(title)
//                    .lineLimit(1)
//            } icon: {
//                Image(systemName: "doc.plaintext")
//            }
//        }
//    }
//
//    private var title: String {
//        guard let subscribe = subscribe.subscribes.first(where: { $0.id == current.wrappedValue }) else {
//            return "默认"
//        }
//        return subscribe.extend.alias
//    }
//}
