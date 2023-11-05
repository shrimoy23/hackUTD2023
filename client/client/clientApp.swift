import SwiftUI

@main
struct RenoVisionAIApp: App {
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 20, weight: .medium)]
        appearance.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 34, weight: .bold)]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
 
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.font, Font.custom("Helvetica Neue", size: 17))
        }
    }
}
