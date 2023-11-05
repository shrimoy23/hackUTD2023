import SwiftUI

struct PropertyInputView: View {
    @Binding var isPresentingCamera: Bool
    @State private var address: String = ""
    @State private var squareFootage: String = ""
    @Environment(\.presentationMode) var presentationMode
    var firestoreService: FirestoreService // Pass the FirestoreService instance
    
    // Computed property to determine if the input is valid
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
                .disabled(!isInputValid) // Disable the button if the input is not valid
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
                // The property was added successfully
                DispatchQueue.main.async {
                    // Start the camera session
                    self.isPresentingCamera = true
                    // Dismiss the current view
                    self.presentationMode.wrappedValue.dismiss()
                }
            } else if let error = error {
                // An error occurred while adding the property
                DispatchQueue.main.async {
                    print("Error adding property: \(error.localizedDescription)")
                    // Handle the error, possibly by showing an alert to the user
                }
            }
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Ensure you provide a `firestoreService` instance when presenting this view
