import Foundation

public enum CityNameValidationError: Error, Equatable {
    case tooShort
    case containsDigits
    case containsDisallowedCharacters
}

public enum CityNameValidator {
    private static let minimumLetterCount = 2

    public static func validate(_ input: String) throws(CityNameValidationError) -> String {
        let name = input
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
            .precomposedStringWithCanonicalMapping

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
