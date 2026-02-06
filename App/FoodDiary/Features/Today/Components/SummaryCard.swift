import SwiftUI

struct SummaryCard: View {
    let count: Int
    
    let dailyCalories: Int
    let dailyProtein: Double
    let dailyCarbs: Double
    let dailyFat: Double
    
    let targetCalories: Int
    let targetProtein: Int
    let targetCarbs: Int
    let targetFat: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header
            HStack {
                Text("Daily amount / target")
                    .font(.headline)
            }
            
            // Total
            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                caloriesRow(label: "Calories", value: dailyCalories, target: targetCalories)
                macroRow(label: "Protein", value: dailyProtein, target: targetProtein)
                macroRow(label: "Carbohydrates", value: dailyCarbs,target: targetCarbs)
                macroRow(label: "Fat", value: dailyFat, target: targetFat)
            }
        }
        .padding()
    }
    
    //Helpers
    
    @ViewBuilder
    private func caloriesRow(label: String, value: Int, target: Int) -> some View {
        
        let valueText = NumberFormatting.whole(Double(value))
        let targetText = NumberFormatting.whole(Double(target))

        GridRow {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("\(valueText) / \(targetText) kcal")
                .font(.caption2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    @ViewBuilder
    private func macroRow(label: String, value: Double, target: Int) -> some View {
        let valueText = NumberFormatting.oneDecimalMax(value)
        let targetText = NumberFormatting.whole(Double(target))

        GridRow {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("\(valueText) / \(targetText) g")
                .font(.caption2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
