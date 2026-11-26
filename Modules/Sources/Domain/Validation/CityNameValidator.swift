import Foundation

public enum CityNameValidationError: Error, Equatable {
    case containsDigits
    case containsDisallowedCharacters
}

public enum CityNameValidator {
    private static let minimumLetterCount = 2

    public static func validate(_ input: String) throws(CityNameValidationError) -> String? {
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
        guard name.count(where: \.isLetter) >= Self.minimumLetterCount else {
            return nil
        }
        return name
    }

    private static func isAllowed(_ character: Character) -> Bool {
        character.isLetter || character == " " || character == "-"
    }
}
