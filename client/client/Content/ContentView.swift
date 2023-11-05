import SwiftUI
import SwiftData
import MetalKit

struct GraphView: View {
    var body: some View {
        VStack {
            Text("Graph for Home Analysis")
                .font(.title)
                .padding()
            Rectangle()
                .fill(Color(red: 255 / 255, green: 229 / 255, blue: 217 / 255))
                .frame(height: 200)
                .cornerRadius(12)
                .padding()
        }
    }
}

struct HouseIconView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(red: 255 / 255, green: 229 / 255, blue: 217 / 255))
                .frame(width: 36, height: 30)
                .offset(y: 5)
            
            Triangle()
                .fill(Color.red)
                .frame(width: 50, height: 30)
                .offset(y: -15)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

        return path
    }
}

struct HomeCardView: View {
    var property: Property
    
    var body: some View {
        HStack {
            HouseIconView()
                .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text("Home \(property.address)")
                    .font(.headline)
                    .foregroundColor(Color.black)
                Text("Details for Home \(property.squareFootage) sq ft")
                    .font(.subheadline)
                    .foregroundColor(Color.black)
            }
            Spacer()
        }
        .padding(.vertical)
    }
}

struct HomeDetailsView: View {
    var property: Property
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Home \(property.address) Details")
                .font(.headline)
            GraphView()
        }
        .padding()
        .navigationTitle("Details for Home \(property.address)")
        .navigationBarBackButtonHidden(true)
    }
}

struct ARDisplayView: View {
    @ObservedObject var coordinator: Coordinator
    @Binding var isPresenting: Bool

    var body: some View {
        let bounds = UIScreen.main.bounds
        
        ZStack {
            MetalView(coordinator: coordinator)
                .disabled(false)
                .frame(width: bounds.height, height: bounds.width)
                .rotationEffect(.degrees(90))
                .position(x: bounds.width * 0.5, y: bounds.height * 0.5)
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isPresenting = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

struct MetalView: UIViewRepresentable {
    @ObservedObject var coordinator: Coordinator
    
    func makeCoordinator() -> Coordinator {
        coordinator
    }
    
    func makeUIView(context: Context) -> MTKView {
        context.coordinator.view
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {}
}

struct ContentView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var firestoreService = FirestoreService()
    @State private var properties: [Property] = []
    @State private var showingPropertyInputView = false
    @State private var showingCameraView = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background color extending to the top of the screen
                Color("YourBackgroundColor") // Replace with your color
                    .edgesIgnoringSafeArea(.all)

                // Main content
                VStack(spacing: 0) {
                    // Property cards container
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Existing properties
                            ForEach(properties, id: \.id) { property in
                                HomeCardView(property: property)
                                    .background(Color("YourCardBackgroundColor")) // Replace with your color
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            if let index = properties.firstIndex(where: { $0.id == property.id }) {
                                                deleteProperty(at: IndexSet(integer: index))
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        fetchProperties()
                    }

                    // Add new property button
                    Button(action: {
                        showingPropertyInputView = true
                    }) {
                        Text("Add New Property")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue) // Replace with your color
                            .cornerRadius(10)
                    }
                    .padding()
                    .sheet(isPresented: $showingPropertyInputView) { // This should be $showingPropertyInputView
                        PropertyInputView(isPresentingCamera: $showingCameraView, firestoreService: firestoreService)
                    }

                }
            }
            .navigationBarItems(trailing: Button("Refresh") {
                fetchProperties()
            })
            .onAppear {
                fetchProperties()
            }
        }
    }

    private func fetchProperties() {
        firestoreService.fetchProperties { properties, error in
            if let properties = properties {
                self.properties = properties
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    private func addProperty(address: String, squareFootage: Int) {
        firestoreService.addProperty(address: address, squareFootage: squareFootage) { success, error in
            if success {
                fetchProperties()
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }


    private func deleteProperty(at offsets: IndexSet) {
        for index in offsets {
            let property = properties[index]
            if let propertyId = property.id {
                firestoreService.deleteProperty(propertyId) { success, error in
                    if success {
                        DispatchQueue.main.async {
                            properties.remove(atOffsets: offsets)
                        }
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }

}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
