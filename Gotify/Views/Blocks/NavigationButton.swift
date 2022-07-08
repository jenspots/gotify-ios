//
// https://stackoverflow.com/a/58908409
//

import Foundation
import SwiftUI

struct NavigationButton<Destination: View, Label: View>: View {
    var action: () -> Void = { }
    var destination: () -> Destination
    var label: () -> Label

    @Environment(\.colorScheme) private var colorScheme
    @State private var isActive: Bool = false

    var body: some View {
        Button(action: {
            self.action()
            self.isActive.toggle()
        }) {
            self.label()
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .background(
                    ScrollView { // Fixes a bug where the navigation bar may become hidden on the pushed view
                        NavigationLink(destination: LazyDestination { self.destination() },
                            isActive: self.$isActive) { EmptyView() }
                    }
                )
        }
    }
}

// This view lets us avoid instantiating our Destination before it has been pushed.
fileprivate struct LazyDestination<Destination: View>: View {
    var destination: () -> Destination
    var body: some View {
        self.destination()
    }
}
