import SwiftUI

final class CFILoadingViewModel: ObservableObject {
    
    enum State: Equatable {
        
        case loading(String)
        case success(String)
        case failure(String)
        
        var message: String {
            switch self {
            case .loading(let value):
                return value
            case .success(let value):
                return value
            case .failure(let value):
                return value
            }
        }
    }
    
    @Published var isPresented = false
    @Published var state: State = .loading("")
    
    func loading(message: String) {
        isPresented = true
        state = .loading(message)
    }
    
    func success(message: String) {
        isPresented = true
        state = .success(message)
    }
    
    func failure(message: String) {
        isPresented = true
        state = .failure(message)
    }
}

struct CFILoadingView: View {
    
    let state: Binding<CFILoadingViewModel.State>
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            
            Group {
                switch state.wrappedValue {
                case .loading:
                    ProgressView()
                case .success:
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                case .failure:
                    Image(systemName: "xmark")
                        .foregroundColor(.red)
                }
            }
            .frame(width: 18.0)
            
            Text(state.wrappedValue.message)
                .lineLimit(1)
            
            Spacer()
            
            if !isInLoading {
                Button {
                    dismiss()
                } label: {
                    Text("好的")
                }
            }
        }
        .padding(.horizontal, 15)
        .interactiveDismissDisabled(true)
    }
    
    private var isInLoading: Bool {
        switch self.state.wrappedValue {
        case .loading:
            return true
        case .success, .failure:
            return false
        }
    }
}
