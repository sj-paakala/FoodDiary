import Testing
@testable import FoodDiary

struct NumberFormattingTests {

    @Test func parseEmptyIsNil() {
        #expect(NumberFormatting.parse("") == nil)
        #expect(NumberFormatting.parse("   ") == nil)
    }

    @Test func parseInteger() {
        #expect(NumberFormatting.parse("150") == 150.0)
    }

    @Test func parseDotDecimal() {
        #expect(NumberFormatting.parse("12.5") == 12.5)
    }

    @Test func parseCommaDecimal() {
        #expect(NumberFormatting.parse("12,5") == 12.5)
    }
}
