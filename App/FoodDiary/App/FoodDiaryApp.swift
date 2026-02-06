import SwiftUI
import SwiftData

@main
struct FoodDiaryApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: [FoodEntry.self, FavoriteFood.self])
    }
}
