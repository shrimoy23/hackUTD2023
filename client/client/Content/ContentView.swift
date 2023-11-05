import SwiftUI
import SwiftData

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

import SwiftUI

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

// Usage in HomeCardView
struct HomeCardView: View {
    var homeNumber: Int

    var body: some View {
        HStack {
            HouseIconView()
                .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text("Home \(homeNumber)")
                    .font(.headline)
                    .foregroundColor(Color.black)
                Text("Details for Home \(homeNumber)")
                    .font(.subheadline)
                    .foregroundColor(Color.black)
            }
            Spacer()
        }
        .padding(.vertical)
    }
}



struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var homeCount: Int = 0
    @State private var showingCameraView = false

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(0..<homeCount, id: \.self) { count in
                    NavigationLink(destination: HomeDetailsView(homeNumber: count + 1)) {
                        HomeCardView(homeNumber: count + 1)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("RenoVisionAI")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .overlay(
                VStack {
                    Spacer()
                    Button(action: {
                        addItem()
                        showingCameraView = true
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
            .sheet(isPresented: $showingCameraView) {
                CustomARViewRepresentable()
            }
        } detail: {
            if homeCount > 0 {
                HomeDetailsView(homeNumber: homeCount)
            } else {
                Text("Select a home")
            }
        }
        .background(Color(red: 250 / 255, green: 225 / 255, blue: 220 / 255))
        .edgesIgnoringSafeArea(.all)
    }

    private func addItem() {
        withAnimation {
            homeCount += 1
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            homeCount -= offsets.count
        }
    }
}

struct HomeDetailsView: View {
    var homeNumber: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text("Home \(homeNumber) Details")
                .font(.headline)
            GraphView()
        }
        .padding()
        .navigationTitle("Details for Home \(homeNumber)")
        .navigationBarBackButtonHidden(true)
    }
}
