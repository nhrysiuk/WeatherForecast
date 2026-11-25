import Domain
import Foundation
import Testing

struct CityNameValidatorTests {
    @Test(arguments: ["Łódź", "Zielona Góra", "Kędzierzyn-Koźle", "Zürich", "São Paulo"])
    func acceptsValidNames(_ name: String) throws {
        #expect(try CityNameValidator.validate(name) == name)
    }

    @Test func trimsAndCollapsesWhitespace() throws {
        #expect(try CityNameValidator.validate("  Nowy   Sącz \n") == "Nowy Sącz")
    }

    @Test func composesDecomposedLetters() throws {
        let decomposed = "Gdańsk".decomposedStringWithCanonicalMapping

        #expect(try CityNameValidator.validate(decomposed) == "Gdańsk")
    }

    @Test(arguments: ["Warszawa2", "Łódź½"])
    func rejectsDigits(_ name: String) {
        #expect(throws: CityNameValidationError.containsDigits) {
            try CityNameValidator.validate(name)
        }
    }

    @Test(arguments: ["Kraków!", "St. Albans", "O'Hare", "Wrocław🌧"])
    func rejectsSpecialCharacters(_ name: String) {
        #expect(throws: CityNameValidationError.containsDisallowedCharacters) {
            try CityNameValidator.validate(name)
        }
    }

    @Test(arguments: ["", "   ", "Ł", "- -"])
    func rejectsTooShortNames(_ name: String) {
        #expect(throws: CityNameValidationError.tooShort) {
            try CityNameValidator.validate(name)
        }
    }
}
