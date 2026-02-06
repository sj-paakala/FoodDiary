import SwiftUI

struct FavoriteRow: View {
    let favorite: FavoriteFood
    let onAdd: () -> Void

    var body: some View {
        FoodRow(
            title: favorite.name,
            topRight: {
                ButtonPill(title: "Add to diary", action: onAdd)
                    .buttonStyle(.borderless)
                .accessibilityLabel("Add \(favorite.name) to diary")
            },
            caloriesText: favorite.calories.map { NumberFormatting.whole(Double($0)) } ?? "—",
            proteinText: macroText(favorite.protein),
            carbsText: macroText(favorite.carbs),
            fatText: macroText(favorite.fat)
        )
    }

    private func macroText(_ value: Double?) -> String {
        guard let value else { return "—" }
        return NumberFormatting.oneDecimalMax(value)
    }
}
