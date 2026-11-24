public enum SearchHistoryStoreError: Error, Equatable {
    case unsupportedVersion(Int)
    case unknownTimeZone(String)
}
