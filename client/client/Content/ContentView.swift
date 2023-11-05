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
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var homeCount: Int = 0
    @State private var showingCameraView = false
    @State private var showingPropertyInputView = false
    @StateObject private var firestoreService = FirestoreService()
    @StateObject var coordinator = Coordinator()

    @State private var properties: [Property] = []

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(properties, id: \.id) { property in
                    NavigationLink(destination: HomeDetailsView(property: property)) {
                        HomeCardView(property: property)
                    }
                }
                .onDelete(perform: deleteProperty)
            }
            .navigationTitle("RenoVisionAI")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingPropertyInputView.toggle()
                    }) {
                        Label("Add Property", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .overlay(
                VStack {
                    Spacer()
                    Button(action: {
                        addItem()
                        showingCameraView.toggle()
                    }) {
                        Text("Scan New Property")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundColor(.white)
                            .background(Color(red: 4 / 255, green: 60 / 255, blue: 128 / 255))
                            .cornerRadius(10)
                    }
                    .padding()
                }
            )
            .sheet(isPresented: $showingPropertyInputView) {
                PropertyInputView(isPresentingCamera: $showingCameraView)
            }
            .sheet(isPresented: $showingCameraView) {
                ARDisplayView(coordinator: coordinator, isPresenting: $showingCameraView)
            }
        } detail: {
            if !properties.isEmpty {
                HomeDetailsView(property: properties.first!)
            } else {
                Text("Select a home")
            }
        }
        .background(Color(red: 250 / 255, green: 225 / 255, blue: 220 / 255))
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            fetchProperties()
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
            firestoreService.deleteProperty(property.id) { success, error in
                if success {
                    properties.remove(at: index)
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            homeCount += 1
            showingPropertyInputView = true
        }
    }
}
