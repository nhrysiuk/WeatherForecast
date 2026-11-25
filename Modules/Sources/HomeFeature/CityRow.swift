import Domain
import SwiftUI

struct CityRow: View {
    let city: City

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(city.name)
                .font(.headline)
            if !details.isEmpty {
                Text(details)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var details: String {
        let country = city.countryCode.flatMap { Locale.current.localizedString(forRegionCode: $0) }
        return [city.region, country].compactMap(\.self).joined(separator: ", ")
    }
}
