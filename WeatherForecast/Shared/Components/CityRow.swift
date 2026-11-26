import Domain
import SwiftUI

struct CityRow: View {
    let city: City

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 6))
            : AnyLayout(HStackLayout(spacing: 14))
        layout {
            badge
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
    }

    @ViewBuilder
    private var badge: some View {
        if let flag {
            Text(flag)
                .font(.title)
        } else {
            Image(systemName: "globe.europe.africa.fill")
                .font(.title)
                .symbolRenderingMode(.multicolor)
        }
    }

    private var flag: String? {
        guard let code = city.countryCode?.uppercased(), code.count == 2 else {
            return nil
        }
        let scalars = code.unicodeScalars.compactMap { Unicode.Scalar(0x1F1A5 + $0.value) }
        guard scalars.count == 2, code.allSatisfy(\.isASCII), code.allSatisfy(\.isLetter) else {
            return nil
        }
        return String(String.UnicodeScalarView(scalars))
    }

    private var details: String {
        let country = city.countryCode.flatMap { Locale.current.localizedString(forRegionCode: $0) }
        return [city.region, country].compactMap(\.self).joined(separator: ", ")
    }
}
