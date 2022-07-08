//
//  KeyValueText.swift
//  Gotify
//
//  Created by Jens Pots on 02/07/2022.
//

import SwiftUI

struct KeyValueText: View {
    @Binding var left: String
    @Binding var right: String
    private var hidden: Bool

    init(left: Binding<String>, right: Binding<String>, hidden: Bool = false) {
        self._left = left
        self._right = right
        self.hidden = hidden
    }

    init(left: String, right: String, hidden: Bool = false) {
        self._left = Binding(get: { left }, set: { _ in fatalError("Not a binding") })
        self._right = Binding(get: { right }, set: { _ in fatalError("Not a binding") })
        self.hidden = hidden
    }

    init(left: String, right: Binding<String>, hidden: Bool = false) {
        self._left = Binding(get: { left }, set: { _ in fatalError("Not a binding") })
        self._right = right
        self.hidden = hidden
    }

    init(left: Binding<String>, right: String, hidden: Bool = false) {
        self._left = left
        self._right = Binding(get: { right }, set: { _ in fatalError("Not a binding") })
        self.hidden = hidden
    }


    var body: some View {
        HStack {
            Text(left)
                .lineLimit(1)
            Spacer()
            Text(right)
                .foregroundColor(.gray)
                .lineLimit(1)
                .redacted(reason: hidden ? .placeholder : .privacy)
        }
    }
}
