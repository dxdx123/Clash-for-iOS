import SwiftUI

final class CFIStatisticViewModel: ObservableObject {
    
    private let current: String
    
    init(current: String) {
        self.current = current
    }
    
    func load() async throws {
        
    }
}

struct CFIStatisticView: View {
    
    @StateObject private var viewModel: CFIStatisticViewModel
    
    init(current: String) {
        self._viewModel = StateObject(wrappedValue: CFIStatisticViewModel(current: current))
    }
    
    var body: some View {
        Form {
            
        }
        .formStyle(.grouped)
        .navigationTitle(Text("统计"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                try await viewModel.load()
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
