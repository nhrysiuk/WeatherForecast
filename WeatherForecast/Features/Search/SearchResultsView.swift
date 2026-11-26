import Domain
import SwiftUI

struct SearchResultsView: View {
    let search: SearchViewModel
    let open: (City) -> Void

    var body: some View {
        switch search.state {
        case .loading:
            CityRowsSkeleton()
        case .results(let cities):
            ForEach(cities) { city in
                CityLink(city: city, open: open) {
                    CityRow(city: city)
                }
            }
        case .idle, .invalid, .failed:
            EmptyView()
        }
    }
}
