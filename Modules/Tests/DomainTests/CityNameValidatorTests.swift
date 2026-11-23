import Domain
import Testing

struct CityNameValidatorTests {
    private let validator = CityNameValidator()

    @Test(arguments: [
        "Warszawa",
        "Łódź",
        "Zielona Góra",
        "Bielsko-Biała",
        "Kędzierzyn-Koźle",
        "Zürich",
        "São Paulo",
    ])
    func acceptsValidNames(_ name: String) throws {
        #expect(try validator.validate(name) == name)
    }

    @Test func trimsAndCollapsesWhitespace() throws {
        #expect(try validator.validate("  Nowy   Sącz \n") == "Nowy Sącz")
    }

    @Test func composesDecomposedLetters() throws {
        // "n" followed by a combining acute accent, as some keyboards and pastes produce.
        let decomposed = "Gda\u{0144}sk".decomposedStringWithCanonicalMapping
        #expect(decomposed.unicodeScalars.count > "Gdańsk".unicodeScalars.count)

        #expect(try validator.validate(decomposed) == "Gdańsk")
    }

    @Test(arguments: ["Warszawa2", "1", "Kraków 3", "Łódź½"])
    func rejectsDigits(_ name: String) {
        #expect(throws: CityNameValidationError.containsDigits) {
            try validator.validate(name)
        }
    }

    @Test(arguments: ["Kraków!", "Gdańsk_", "St. Petersburg", "O'Hare", "Poznań/Wilda", "Wrocław🌧"])
    func rejectsSpecialCharacters(_ name: String) {
        #expect(throws: CityNameValidationError.containsDisallowedCharacters) {
            try validator.validate(name)
        }
    }

    @Test func digitsAreReportedBeforeOtherCharacters() {
        #expect(throws: CityNameValidationError.containsDigits) {
            try validator.validate("Kraków-2!")
        }
    }

    @Test(arguments: ["", "   ", "A", "-", "- -", "Ł-"])
    func rejectsTooShortNames(_ name: String) {
        #expect(throws: CityNameValidationError.tooShort) {
            try validator.validate(name)
        }
    }
}
