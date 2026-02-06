import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddFavorite = false
    @State private var editingFavorite: FavoriteFood?

    @Query(sort: [SortDescriptor(\FavoriteFood.createdAt, order: .reverse)])
    private var favorites: [FavoriteFood]

    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    ContentUnavailableView(
                        "No favorites yet",
                        systemImage: "star",
                        description: Text("Add foods you eat often for quick logging.")
                    )
                    .padding(.top, 24)
                } else {
                    List {
                      ForEach(favorites) { fav in
                        Button {
                          editingFavorite = fav
                        } label: {
                          FavoriteRow(favorite: fav, onAdd: { addToToday(fav) })
                        }
                        .buttonStyle(.plain)
                      }
                      .onDelete { indexSet in
                            for idx in indexSet {
                                modelContext.delete(favorites[idx])
                            }
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddFavorite = true
                    } label: {
                        Image(systemName: "plus")
                            .accessibilityLabel("Add favorite")
                    }
                    .accessibilityLabel("Add favorite")
                }
            }
            .sheet(isPresented: $showingAddFavorite) {
                FavoriteFormView(mode: .add) { name, calories, protein, carbs, fat in
                    modelContext.insert(
                        FavoriteFood(
                            name: name,
                            calories: calories,
                            protein: protein,
                            carbs: carbs,
                            fat: fat
                        )
                    )
                }
            }
            .sheet(item: $editingFavorite) { fav in
                FavoriteFormView(mode: .edit(fav)) { name, calories, protein, carbs, fat in
                    fav.name = name
                    fav.calories = calories
                    fav.protein = protein
                    fav.carbs = carbs
                    fav.fat = fat
                }
            }
        }
    }

    private func addToToday(_ fav: FavoriteFood) {
        modelContext.insert(
            FoodEntry(
                name: fav.name,
                timestamp: .now,
                calories: fav.calories,
                protein: fav.protein,
                carbs: fav.carbs,
                fat: fav.fat
            )
        )
    }
}
