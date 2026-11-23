import Foundation

public enum CityNameValidationError: Error, Hashable, Sendable {
    /// Fewer letters than `CityNameValidator.minimumLetterCount`, including empty input.
    case tooShort
    case containsDigits
    /// Anything other than letters, spaces and hyphens.
    case containsDisallowedCharacters
}

/// Checks a city name typed by the user before it is sent to search.
///
/// Rules: no digits; the only allowed special characters are space and hyphen;
/// letters from any alphabet are accepted, so Polish names ("Łódź") and foreign
/// ones ("Zürich") both pass.
public struct CityNameValidator: Sendable {
    /// Geocoding returns nothing useful for a single letter.
    public static let minimumLetterCount = 2

    public init() {}

    /// Returns the name ready for search: whitespace trimmed and collapsed
    /// to single spaces, Unicode composed (NFC).
    public func validate(_ input: String) throws(CityNameValidationError) -> String {
        let name = input
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
            .precomposedStringWithCanonicalMapping

        // Checked per Character (grapheme cluster), not per Unicode scalar,
        // so a letter followed by a combining mark counts as one letter.
        if name.contains(where: \.isNumber) {
            throw .containsDigits
        }
        if name.contains(where: { !Self.isAllowed($0) }) {
            throw .containsDisallowedCharacters
        }
        if name.count(where: \.isLetter) < Self.minimumLetterCount {
            throw .tooShort
        }
        return name
    }

    private static func isAllowed(_ character: Character) -> Bool {
        character.isLetter || character == " " || character == "-"
    }
}
