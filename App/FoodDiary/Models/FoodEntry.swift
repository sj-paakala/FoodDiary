import Foundation
import SwiftData

@Model
final class FoodEntry {
    var name: String
    var timestamp: Date
    
    var calories: Int?
    var protein: Double?
    var carbs: Double?
    var fat: Double?


    init(
        name: String,
        timestamp: Date = .now,
        calories: Int? = nil,
        protein: Double? = nil,
        carbs: Double? = nil,
        fat: Double? = nil
    ) {
        self.name = name
        self.timestamp = timestamp
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
    }
}
