import SwiftUI

struct EntryRow: View {
    let entry: FoodEntry

    var body: some View {
        FoodRow(
            title: entry.name,
            topRight: {
                Text(entry.timestamp, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            },
            caloriesText: NumberFormatting.whole(Double(entry.calories ?? 0)),
            proteinText: macroText(entry.protein),
            carbsText: macroText(entry.carbs),
            fatText: macroText(entry.fat)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
    }

    private func macroText(_ value: Double?) -> String {
        guard let value else { return "—" }
        return NumberFormatting.oneDecimalMax(value)
    }

    private var accessibilitySummary: String {
        let cal = NumberFormatting.whole(Double(entry.calories ?? 0))
        let p = macroText(entry.protein)
        let c = macroText(entry.carbs)
        let f = macroText(entry.fat)
        return "\(entry.name). \(cal) kilocalories. Protein \(p) grams. Carbs \(c) grams. Fat \(f) grams."
    }
}
