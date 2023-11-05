import SwiftUI

struct PropertyInputView: View {
    @Binding var isPresentingCamera: Bool
    @State private var address: String = ""
    @State private var squareFootage: String = ""
    @Environment(\.dismiss) private var dismiss // Dismiss action

    // Computed property to determine if the input is valid
    private var isInputValid: Bool {
        !address.isEmpty && !squareFootage.isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Property Details")) {
                    TextField("Enter address", text: $address)
                    TextField("Square footage", text: $squareFootage)
                        .keyboardType(.numberPad)
                }
                
                Button(action: {
                    if isInputValid {
                        isPresentingCamera = true
                        dismiss() // Dismiss the current view
                    }
                }) {
                    Text("Swipe down to continue")
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .foregroundColor(.white)
                        .background(isInputValid ? Color.blue : Color.gray)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("New Property")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                hideKeyboard()
            }
        }
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct PropertyInputView_Previews: PreviewProvider {
    static var previews: some View {
        PropertyInputView(isPresentingCamera: .constant(false))
    }
}
