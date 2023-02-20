import SwiftUI

struct MPAccentColorView: View {
    
    @AppStorage(MPConstant.accentColor) private var accentColor = MPAccentColor.system
    
    var body: some View {
        NavigationLink {
            MPFormPicker(title: "强调色", selection: $accentColor) {
                ForEach(MPAccentColor.allCases) { color in
                    HStack {
                        ZStack {
                            Circle()
                                .fill(AngularGradient(colors: color.tint.flatMap({ [$0] }) ?? MPAccentColor.allCases.compactMap(\.tint), center: .center))
                        }
                        .frame(width: 20, height: 20)
                        Text(color.name)
                    }
                }
            }
        } label: {
            LabeledContent {
                Text(accentColor.name)
            } label: {
                Label {
                    Text("强调色")
                } icon: {
                    Image(systemName: "scribble.variable")
                }
            }            
        }
    }
}
