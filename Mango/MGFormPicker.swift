import SwiftUI

struct MGFormPicker<SelectionValue, Content>: View where SelectionValue: Hashable, Content: View {
        
    @Environment(\.dismiss) private var dismiss
        
    private let title: any StringProtocol
    private let selection: Binding<SelectionValue>
    private let content: () -> Content
    
    init(title: any StringProtocol, selection: Binding<SelectionValue>, content: @escaping () -> Content) {
        self.title = title
        self.selection = selection
        self.content = content
    }
    
    var body: some View {
        Form {
            Picker(selection: selection) {
                content()
            } label: {
                EmptyView()
            }
            .labelsHidden()
            .pickerStyle(.inline)
        }
        .formStyle(.grouped)
        .navigationTitle(Text(title))
        .onChange(of: selection.wrappedValue) { _ in
            dismiss()
        }
    }
}
