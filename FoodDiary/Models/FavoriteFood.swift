import Foundation
import SwiftData

@Model
final class FavoriteFood {
    var name: String
    var calories: Int?
    var protein: Double?
    var carbs: Double?
    var fat: Double?
    var createdAt: Date

    init(name: String, calories: Int? = nil, protein: Double? = nil, carbs: Double? = nil, fat: Double? = nil, createdAt: Date = .now) {
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.createdAt = createdAt
    }
}
