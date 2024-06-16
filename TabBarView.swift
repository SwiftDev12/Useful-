import SwiftUI

struct TabBarView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)
            
            PhoneInfoView()
                .tabItem {
                    Image(systemName: "phone")
                    Text("Phone Info")
                }
                .tag(1)
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
