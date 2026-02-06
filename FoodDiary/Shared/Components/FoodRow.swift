import SwiftUI

struct FoodRow<TopRight: View>: View {
    let title: String
    let topRight: TopRight

    let caloriesText: String
    let proteinText: String
    let carbsText: String
    let fatText: String

    init(
        title: String,
        @ViewBuilder topRight: () -> TopRight,
        caloriesText: String,
        proteinText: String,
        carbsText: String,
        fatText: String
    ) {
        self.title = title
        self.topRight = topRight()
        self.caloriesText = caloriesText
        self.proteinText = proteinText
        self.carbsText = carbsText
        self.fatText = fatText
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Row header: name + time / action
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer(minLength: 8)

                topRight
            }

            // Macros: stable layout on all widths
            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                GridRow {
                    MacroPill(label: "Calories", valueText: caloriesText, unit: "kcal")
                    MacroPill(label: "Protein", valueText: proteinText, unit: "g")
                }
                GridRow {
                    MacroPill(label: "Carbs", valueText: carbsText, unit: "g")
                    MacroPill(label: "Fat", valueText: fatText, unit: "g")
                }
            }
        }
        .padding(.vertical, 6)
    }
}
