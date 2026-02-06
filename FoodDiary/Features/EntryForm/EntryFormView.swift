import SwiftUI

struct EntryFormView: View {
    enum Mode {
        case add
        case edit(FoodEntry)
    }

    let mode: Mode
    let onSave: (_ name: String, _ timestamp: Date, _ calories: Int?, _ protein: Double?, _ carbs: Double?, _ fat: Double?) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var caloriesText: String = ""
    @State private var proteinText: String = ""
    @State private var carbsText: String = ""
    @State private var fatText: String = ""
    @State private var timestamp: Date = .now

    @FocusState private var focusedField: Field?
    enum Field { case name }

    private var title: String {
        switch mode {
        case .add: "Add Entry"
        case .edit: "Edit Entry"
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

                    TextField("Calories kcal", text: $caloriesText)
                        .keyboardType(.numberPad)

                    TextField("Protein (g)", text: $proteinText)
                        .keyboardType(.decimalPad)

                    TextField("Carbs (g)", text: $carbsText)
                        .keyboardType(.decimalPad)

                    TextField("Fat (g)", text: $fatText)
                        .keyboardType(.decimalPad)
                }

                Section("Time") {
                    DatePicker("Time", selection: $timestamp)
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

                        onSave(trimmedName, timestamp, calories, protein, carbs, fat)
                        dismiss()
                    }
                    .disabled(trimmedName.isEmpty)
                }
            }
            .onAppear {
                switch mode {
                case .add:
                    focusedField = .name
                    timestamp = .now

                case .edit(let entry):
                    name = entry.name
                    timestamp = entry.timestamp

                    caloriesText = entry.calories.map(String.init) ?? ""
                    proteinText = entry.protein.map { NumberFormatting.oneDecimalMax($0) } ?? ""
                    carbsText   = entry.carbs.map   { NumberFormatting.oneDecimalMax($0) } ?? ""
                    fatText     = entry.fat.map     { NumberFormatting.oneDecimalMax($0) } ?? ""
                }
            }
        }
    }

    // Calories are stored as Int?, so we parse as Double first, then round/truncate safely.
    private func parseCalories(_ text: String) -> Int? {
        guard let value = NumberFormatting.parse(text) else { return nil }

        // .rounded() = normal rounding; Int(value) truncates toward zero.
        return Int(value)
    }
}
