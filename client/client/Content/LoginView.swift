import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("RenoVisionAI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.blue)
                    .padding()
                    .accessibilityAddTraits(.isHeader)
                
                Image("RenoVisionAILogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 50)
                
                VStack(spacing: 15) {
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal, 24)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal, 24)
                }
                .padding(.bottom, 20)

                NavigationLink(destination: ContentView()) {
                    Text("Sign In")
                        .frame(minWidth: 0, maxWidth: 250)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .bold))
                        .background(Color.blue)
                        .cornerRadius(25)
                }
                
                Spacer()
                Spacer()
            }
            .ignoresSafeArea(edges: .top) // This will extend the background color to the top of the screen
            .navigationBarBackButtonHidden(true)
            .font(.custom("Helvetica Neue", size: 17)) // Sets a custom font for all text within LoginView
            .navigationBarBackButtonHidden(true)
        }
    }
}
