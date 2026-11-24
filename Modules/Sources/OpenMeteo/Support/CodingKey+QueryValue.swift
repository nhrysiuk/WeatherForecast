extension CaseIterable where Self: CodingKey & Equatable {
    static func queryValue(excluding excluded: Self...) -> String {
        allCases
            .filter { !excluded.contains($0) }
            .map(\.stringValue)
            .joined(separator: ",")
    }
}
