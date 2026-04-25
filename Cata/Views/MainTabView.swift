import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState

        TabView(selection: $state.selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(AppState.Tab.home)

            ProgressTabView()
                .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
                .tag(AppState.Tab.progress)

            LifeInWeeksView()
                .tabItem { Label("Life", systemImage: "circle.grid.3x3.fill") }
                .tag(AppState.Tab.life)
        }
        .tint(Color.cataTerra)
    }
}
