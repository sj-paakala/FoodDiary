//
//  NumberFormatting.swift
//  FoodDiary
//
//  Created by Santeri Paakala on 5.2.2026.
//

import Foundation

enum NumberFormatting {
    // Formatter: "12" (no decimals), locale-aware grouping if desired
    static func whole(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0)))
    }

    // If we ever want 0–1 decimals
    static func oneDecimalMax(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...1)))
    }

    // Parser: accepts "12", "12.5", and in Finnish locale also "12,5"
    static func parse(_ text: String) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // 1) Try normal Double first (handles 12 and 12.5)
        if let direct = Double(trimmed) { return direct }

        // 2) Try locale-aware NumberFormatter (handles 12,5 in fi_FI)
        let nf = NumberFormatter()
        nf.locale = .current
        nf.numberStyle = .decimal
        if let number = nf.number(from: trimmed) {
            return number.doubleValue
        }

        // 3) Last resort: swap comma to dot
        let swapped = trimmed.replacingOccurrences(of: ",", with: ".")
        return Double(swapped)
    }
}
