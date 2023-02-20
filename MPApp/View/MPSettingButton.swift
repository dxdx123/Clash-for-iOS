import SwiftUI

struct MPSettingButton<ContentView: View>: View {
    
    @State private var isPresented = false
    
    private let content: () -> ContentView
    
    init(content: @escaping () -> ContentView) {
        self.content = content
    }
    
    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            Image(systemName: "slider.horizontal.3")
        }
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                content()
                    .navigationTitle(Text("设置"))
                    .navigationBarTitleDisplayMode(.inline)
                    .safeAreaInset(edge: .bottom) {
                        Text(version)
                            .foregroundColor(.secondary)
                            .font(.caption)
                            .fontWeight(.light)
                            .monospacedDigit()
                    }
            }
        }
    }
    
    private var version: String {
        guard let info = Bundle.main.infoDictionary,
              let version = info["CFBundleShortVersionString"] as? String else {
            return "--"
        }
        return "版本: \(version)"
    }
}
