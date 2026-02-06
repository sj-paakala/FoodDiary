import SwiftUI

struct AppRootView: View {
    @AppStorage("appTheme") private var appThemeRaw: String = AppTheme.system.rawValue
    
    private var theme: AppTheme {
        AppTheme(rawValue: appThemeRaw) ?? .system
    }
    
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "list.bullet")
                }

            FavoritesView()
                .tabItem {
                    Label("Favorite Food", systemImage: "star.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .preferredColorScheme(theme.colorScheme)
    }
}
