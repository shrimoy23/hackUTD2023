import SwiftUI

struct PropertyInputView: View {
    @Binding var isPresentingCamera: Bool
    @State private var address: String = ""
    @State private var squareFootage: String = ""
    @Environment(\.presentationMode) var presentationMode
    var firestoreService: FirestoreService
    
    private var isInputValid: Bool {
        return !address.isEmpty && Int(squareFootage) != nil
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
                    print("Start Scanning button tapped")
                    if isInputValid {
                        addPropertyAndStartScanning()
                    }
                }) {
                    Text("Start Scanning")
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .foregroundColor(.white)
                        .background(isInputValid ? Color.blue : Color.gray)
                        .cornerRadius(8)
                }
                .disabled(!isInputValid)
            }
            .navigationTitle("New Property")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func addPropertyAndStartScanning() {
        guard let squareFootageInt = Int(squareFootage), !address.isEmpty else { return }
        
        firestoreService.addProperty(address: address, squareFootage: squareFootageInt) { success, error in
            if success {
                DispatchQueue.main.async {
                    self.isPresentingCamera = true
                    self.presentationMode.wrappedValue.dismiss()
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    print("Error adding property: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
