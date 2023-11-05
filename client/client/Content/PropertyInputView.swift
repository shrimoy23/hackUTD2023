import SwiftUI

struct PropertyInputView: View {
    @Binding var isPresentingCamera: Bool
    @State private var address: String = ""
    @State private var squareFootage: Int?

    private let squareFootageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0 // Assuming square footage is always an integer
        return formatter
    }()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Property Details")) {
                    TextField("Enter address", text: $address)
                    TextField("Square footage", value: $squareFootage, formatter: squareFootageFormatter)
                        .keyboardType(.numberPad)
                }
                
                Button(action: {
                    isPresentingCamera = true
                }) {
                    Text("Start Scanning")
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .foregroundColor(.white)
                        .background(Color.blue) // Always blue regardless of validation
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

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct PropertyInputView_Previews: PreviewProvider {
    static var previews: some View {
        PropertyInputView(isPresentingCamera: .constant(false))
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
