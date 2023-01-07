import SwiftUI

struct CFIAccentColorView: View {
    
    @AppStorage(CFIConstant.accentColor) private var accentColor = CFIAccentColor.system
    
    var body: some View {
        NavigationLink {
            Form {
                Picker(selection: $accentColor) {
                    ForEach(CFIAccentColor.allCases) { color in
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(AngularGradient(colors: color.tint.flatMap({ [$0] }) ?? CFIAccentColor.allCases.compactMap(\.tint), center: .center))
                                Circle()
                                    .frame(width: 8, height: 8)
                                    .foregroundColor(accentColor == color ? .white : .clear)
                            }
                            .frame(width: 20, height: 20)
                            Text(color.name)
                        }
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.inline)
            }
            .navigationTitle(Text("强调色"))
            .navigationBarTitleDisplayMode(.inline)
        } label: {
            LabeledContent {
                Text(accentColor.name)
            } label: {
                Label {
                    Text("强调色")
                } icon: {
                    CFIIcon(systemName: "scribble.variable", backgroundColor: .accentColor)
                }
            }            
        }
    }
}
