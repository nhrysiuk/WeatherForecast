extension HourlyForecast {
    static let unstableCape = 1000.0
    static let unstableLiftedIndex = -2.0

    public var hasThunderstormRisk: Bool {
        if condition == .thunderstorm {
            return true
        }
        guard let cape, let liftedIndex else {
            return false
        }
        return cape >= Self.unstableCape && liftedIndex <= Self.unstableLiftedIndex
    }
}
