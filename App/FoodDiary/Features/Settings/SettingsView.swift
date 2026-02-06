import SwiftUI

// Theme

enum AppTheme: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "System"
        case .light:  "Light"
        case .dark:   "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light:  .light
        case .dark:   .dark
        }
    }
}

// Target picker model

private struct TargetPicker: Identifiable {
    enum Kind: String {
        case calories, protein, carbs, fat
    }

    let kind: Kind
    let title: String
    let range: ClosedRange<Int>
    let suffix: String
    let value: Binding<Int>

    var id: String { kind.rawValue }
}

struct SettingsView: View {

    // Targets
    @AppStorage("targetCalories") private var targetCalories: Int = 2200
    @AppStorage("targetProtein") private var targetProtein: Int = 150
    @AppStorage("targetCarbs")   private var targetCarbs: Int = 250
    @AppStorage("targetFat")     private var targetFat: Int = 70

    // Theme
    @AppStorage("appTheme") private var appThemeRaw: String = AppTheme.system.rawValue

    // Demo settings
    @AppStorage("useGrams") private var useGrams: Bool = true
    @AppStorage("remindersEnabled") private var remindersEnabled: Bool = false

    @State private var activeTargetPicker: TargetPicker?

    private var appTheme: AppTheme {
        get { AppTheme(rawValue: appThemeRaw) ?? .system }
        set { appThemeRaw = newValue.rawValue }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily targets") {
                    tappableTargetRow(
                        kind: .calories,
                        title: "Calories",
                        value: $targetCalories,
                        range: 0...10000,
                        suffix: "kcal"
                    )

                    tappableTargetRow(
                        kind: .protein,
                        title: "Protein",
                        value: $targetProtein,
                        range: 0...500,
                        suffix: unitSuffix
                    )

                    tappableTargetRow(
                        kind: .carbs,
                        title: "Carbs",
                        value: $targetCarbs,
                        range: 0...1000,
                        suffix: unitSuffix
                    )

                    tappableTargetRow(
                        kind: .fat,
                        title: "Fat",
                        value: $targetFat,
                        range: 0...300,
                        suffix: unitSuffix
                    )

                    Button(role: .destructive) {
                        resetTargets()
                    } label: {
                        Text("Reset targets to defaults")
                    }
                }

                Section("Appearance") {
                    Picker("Theme", selection: $appThemeRaw) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.title).tag(theme.rawValue)
                        }
                    }
                }

                Section("Preferences") {
                    Toggle("Use grams (g)", isOn: $useGrams)

                    Toggle("Reminders (demo)", isOn: $remindersEnabled)
                    if remindersEnabled {
                        Text("Can wire this up to notifications later.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersionString)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .sheet(item: $activeTargetPicker) { picker in
            TargetEditorSheet(
                title: picker.title,
                suffix: picker.suffix,
                range: picker.range,
                value: picker.value
            )
        }
    }

    private var unitSuffix: String { useGrams ? "g" : "units" }

    private func resetTargets() {
        targetCalories = 2200
        targetProtein = 150
        targetCarbs = 250
        targetFat = 70
    }

    private var appVersionString: String {
        let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        let b = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
        return "\(v) (\(b))"
    }

    // Row that opens editor on tap

    @ViewBuilder
    private func tappableTargetRow(
        kind: TargetPicker.Kind,
        title: String,
        value: Binding<Int>,
        range: ClosedRange<Int>,
        suffix: String
    ) -> some View {
        Button {
            activeTargetPicker = TargetPicker(
                kind: kind,
                title: title,
                range: range,
                suffix: suffix,
                value: value
            )
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .foregroundStyle(.primary)
                    Text("\(value.wrappedValue) \(suffix)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
    }
}

// Editor Sheet

private struct TargetEditorSheet: View {
    let title: String
    let suffix: String
    let range: ClosedRange<Int>
    @Binding var value: Int

    @Environment(\.dismiss) private var dismiss
    @State private var textFieldValue: String = ""
    @FocusState private var isValueFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Tappable first row with inline editing
                    HStack(spacing: 8) {
                        Text(title)

                        Spacer()

                        TextField("", text: $textFieldValue)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .focused($isValueFocused)
                            .frame(minWidth: 60) // keeps it usable
                            .textInputAutocapitalization(.never)

                        Text(suffix)
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isValueFocused = true
                    }
                    .onAppear {
                        textFieldValue = String(value)
                    }
                    .onChange(of: textFieldValue) { _, newValue in
                        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }

                        // Accept decimals (decimalPad) but store Int for now
                        if let parsed = NumberFormatting.parse(trimmed) {
                            let v = clamp(Int(parsed.rounded()))
                            value = v
                        }
                    }

                    // Slider (keeps text field in sync)
                    Slider(
                        value: Binding(
                            get: { Double(value) },
                            set: { newVal in
                                let v = clamp(Int(newVal.rounded()))
                                value = v
                                textFieldValue = String(v)
                            }
                        ),
                        in: Double(range.lowerBound)...Double(range.upperBound)
                    )

                } footer: {
                    Text("Allowed range: \(range.lowerBound)–\(range.upperBound) \(suffix)")
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        // If user cleared the field, restore the current value text
                        if textFieldValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            textFieldValue = String(value)
                        }
                        dismiss()
                    }
                }
            }
        }
    }

    private func clamp(_ n: Int) -> Int {
        min(max(n, range.lowerBound), range.upperBound)
    }
}
