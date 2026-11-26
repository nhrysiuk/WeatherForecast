import Domain
import SwiftUI

struct CityLink<Label: View>: View {
    let city: City
    let open: (City) -> Void
    @ViewBuilder let label: Label

    @Environment(\.dismissSearch) private var dismissSearch
    @Environment(\.editMode) private var editMode

    var body: some View {
        Button {
            guard !isEditing else { return }
            dismissSearch()
            open(city)
        } label: {
            HStack(spacing: 0) {
                label
                Spacer(minLength: 14)
                if !isEditing {
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .tint(.primary)
    }

    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing == true
    }
}
