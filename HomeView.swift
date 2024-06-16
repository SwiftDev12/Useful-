import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Welcome to the Home Screen!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
                .multilineTextAlignment(.center)

            Text("This app was made for a laugh. 😂")
                .font(.title2)
                .foregroundColor(.gray)
                .padding(.horizontal)
                .multilineTextAlignment(.center)

            Text("Hope you enjoy this app.")
                .font(.title2)
                .foregroundColor(.gray)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .navigationTitle("Home")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
