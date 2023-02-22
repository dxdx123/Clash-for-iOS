import SwiftUI

struct MGPresentedButton<Label: View, Destination: View>: View {
    
    @State private var isPresented = false
    
    private let destination:    () -> Destination
    private let label:          () -> Label
    
    init(destination: @escaping () -> Destination, label: @escaping () -> Label) {
        self.destination    = destination
        self.label          = label
    }
    
    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            label()
        }
        .sheet(isPresented: $isPresented) {
            destination()
        }
    }
}
