//
// https://stackoverflow.com/a/58908409
//

import Foundation
import SwiftUI

struct NavigationButton<Destination: View, Label: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isActive = false

    var action: () -> Void = { }
    var destination: () -> Destination
    var label: () -> Label

    var body: some View {
        Button {
            action()
            self.isActive.toggle()
        } label: {
            NavigationLink(destination: destination(), isActive: self.$isActive) {
                label().foregroundColor(colorScheme == .dark ? .white : .black)
            }
        }
    }
}
