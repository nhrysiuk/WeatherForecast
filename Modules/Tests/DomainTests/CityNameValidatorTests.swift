import Domain
import Foundation
import Testing

struct CityNameValidatorTests {
    private let validator = CityNameValidator()

    @Test(arguments: ["Łódź", "Zielona Góra", "Kędzierzyn-Koźle", "Zürich", "São Paulo"])
    func acceptsValidNames(_ name: String) throws {
        #expect(try validator.validate(name) == name)
    }

    @Test func trimsAndCollapsesWhitespace() throws {
        #expect(try validator.validate("  Nowy   Sącz \n") == "Nowy Sącz")
    }

    @Test func composesDecomposedLetters() throws {
        let decomposed = "Gdańsk".decomposedStringWithCanonicalMapping

        #expect(try validator.validate(decomposed) == "Gdańsk")
    }

    @Test(arguments: ["Warszawa2", "Łódź½"])
    func rejectsDigits(_ name: String) {
        #expect(throws: CityNameValidationError.containsDigits) {
            try validator.validate(name)
        }
    }

    @Test(arguments: ["Kraków!", "St. Albans", "O'Hare", "Wrocław🌧"])
    func rejectsSpecialCharacters(_ name: String) {
        #expect(throws: CityNameValidationError.containsDisallowedCharacters) {
            try validator.validate(name)
        }
    }

    @Test(arguments: ["", "   ", "Ł", "- -"])
    func rejectsTooShortNames(_ name: String) {
        #expect(throws: CityNameValidationError.tooShort) {
            try validator.validate(name)
        }
    }
}
