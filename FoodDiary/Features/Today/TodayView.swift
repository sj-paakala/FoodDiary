import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingAdd = false
    @State private var editingEntry: FoodEntry?

    private var todayRange: Range<Date> {
        let cal = Calendar.current
        let start = cal.startOfDay(for: .now)
        let end = cal.date(byAdding: .day, value: 1, to: start)!
        return start..<end
    }

    var body: some View {
        NavigationStack {
            TodayContent(
                todayRange: todayRange,
                onAdd: { showingAdd = true },
                onEdit: { editingEntry = $0 }
            )
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                            .accessibilityLabel("Add entry")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                EntryFormView(mode: .add) {
                    name, timestamp, calories, protein, carbs, fat in
                    modelContext.insert(
                        FoodEntry(
                            name: name,
                            timestamp: timestamp,
                            calories: calories.map { Int($0) },
                            protein: protein,
                            carbs: carbs,
                            fat: fat
                        )
                    )
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(mode: .edit(entry)) {
                    name, timestamp, calories, protein, carbs, fat in
                    entry.name = name
                    entry.timestamp = timestamp
                    entry.calories = calories.map { Int($0) }
                    entry.protein = protein
                    entry.carbs = carbs
                    entry.fat = fat
                }
            }
        }
    }
}

/// Split out so we can attach @Query cleanly with a runtime range
private struct TodayContent: View {
    let todayRange: Range<Date>
    let onAdd: () -> Void
    let onEdit: (FoodEntry) -> Void

    @Environment(\.modelContext) private var modelContext

    // Targets from SettingsView (@AppStorage)
    @AppStorage("targetCalories") private var targetCalories: Int = 2200
    @AppStorage("targetProtein")  private var targetProtein: Int = 150
    @AppStorage("targetCarbs")    private var targetCarbs: Int = 250
    @AppStorage("targetFat")      private var targetFat: Int = 70

    @Query private var entries: [FoodEntry]

    init(todayRange: Range<Date>, onAdd: @escaping () -> Void, onEdit: @escaping (FoodEntry) -> Void) {
        self.todayRange = todayRange
        self.onAdd = onAdd
        self.onEdit = onEdit

        _entries = Query(
            filter: #Predicate<FoodEntry> { $0.timestamp >= todayRange.lowerBound && $0.timestamp < todayRange.upperBound },
            sort: [SortDescriptor(\FoodEntry.timestamp, order: .reverse)]
        )
    }

    var dailyCalories: Int {
        entries.reduce(0) { $0 + ($1.calories ?? 0) }
    }
    var dailyProtein: Double {
        entries.reduce(0) { $0 + ($1.protein ?? 0.0) }
    }
    var dailyCarbs: Double {
        entries.reduce(0) { $0 + ($1.carbs ?? 0.0) }
    }
    var dailyFat: Double {
        entries.reduce(0) { $0 + ($1.fat ?? 0.0) }
    }

    var body: some View {
        List {
            Section {
                SummaryCard(
                    count: entries.count,
                    dailyCalories: dailyCalories,
                    dailyProtein: dailyProtein,
                    dailyCarbs: dailyCarbs,
                    dailyFat: dailyFat,
                    
                    targetCalories: targetCalories,
                    targetProtein: targetProtein,
                    targetCarbs: targetCarbs,
                    targetFat: targetFat
                )
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
            }

            if entries.isEmpty {
                Section {
                    ContentUnavailableView(
                        "No entries yet",
                        systemImage: "fork.knife",
                        description: Text("Add your first meal to get started.")
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 2)
                    .listRowBackground(Color.clear)
                }
            } else {
                Section("Today's meals") {
                    ForEach(entries) { entry in
                        Button {
                            onEdit(entry)
                        } label: {
                            EntryRow(entry: entry)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { indexSet in
                        for idx in indexSet {
                            modelContext.delete(entries[idx])
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

