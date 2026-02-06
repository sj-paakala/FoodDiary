import SwiftUI

struct FavoriteFormView: View {
    enum Mode {
        case add
        case edit(FavoriteFood)
    }

    let mode: Mode
    let onSave: (_ name: String, _ calories: Int?, _ protein: Double?, _ carbs: Double?, _ fat: Double?) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var caloriesText: String = ""
    @State private var proteinText: String = ""
    @State private var carbsText: String = ""
    @State private var fatText: String = ""

    @FocusState private var focusedField: Field?
    enum Field { case name }

    private var title: String {
        switch mode {
        case .add: "Add Favorite"
        case .edit: "Edit Favorite"
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Food") {
                    TextField("Name", text: $name)
                        .focused($focusedField, equals: .name)
                        .textInputAutocapitalization(.words)

                    TextField("Calories (kcal)", text: $caloriesText)
                        .keyboardType(.numberPad)

                    TextField("Protein (g)", text: $proteinText)
                        .keyboardType(.decimalPad)

                    TextField("Carbs (g)", text: $carbsText)
                        .keyboardType(.decimalPad)

                    TextField("Fat (g)", text: $fatText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let calories = parseCalories(caloriesText)
                        let protein = NumberFormatting.parse(proteinText)
                        let carbs = NumberFormatting.parse(carbsText)
                        let fat = NumberFormatting.parse(fatText)

                        onSave(trimmedName, calories, protein, carbs, fat)
                        dismiss()
                    }
                    .disabled(trimmedName.isEmpty)
                }
            }
            .onAppear {
                switch mode {
                case .add:
                    focusedField = .name

                case .edit(let fav):
                    name = fav.name

                    caloriesText = fav.calories.map(String.init) ?? ""
                    proteinText = fav.protein.map { NumberFormatting.oneDecimalMax($0) } ?? ""
                    carbsText   = fav.carbs.map   { NumberFormatting.oneDecimalMax($0) } ?? ""
                    fatText     = fav.fat.map     { NumberFormatting.oneDecimalMax($0) } ?? ""
                }
            }
        }
    }

    private func parseCalories(_ text: String) -> Int? {
        guard let value = NumberFormatting.parse(text) else { return nil }
        // Match EntryFormView behavior:
        return Int(value) // truncates; use Int(value.rounded()) if you want rounding
    }
}
