import SwiftUI

struct PropertyInputView: View {
    @Binding var isPresentingCamera: Bool
    @State private var address: String = ""
    @State private var squareFootage: Int?

    var body: some View {
        Form {
            Section(header: Text("Property Details")) {
                TextField("Enter address", text: $address)
                TextField("Square footage", value: $squareFootage, formatter: NumberFormatter())
            }
            
            Button("Start Scanning") {
                // Validate input data
                // Send data to server or save locally as needed
                // Present the camera view
                isPresentingCamera = true
            }
            .disabled(address.isEmpty || squareFootage == nil)
        }
        .navigationTitle("New Property")
    }
}
