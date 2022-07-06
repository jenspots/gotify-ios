//
//  SensitiveText.swift
//  Gotify
//
//  Created by Jens Pots on 01/07/2022.
//

import SwiftUI

struct SensitiveText: View {
    @State var left: String
    @State var right: String
    @State var redact: Bool = true

    var body: some View {
        HStack {
            Text(left)
            Spacer()
            Text(right)
                .foregroundColor(.gray)
                .redacted(reason: redact ? .placeholder : .privacy)
                .onTapGesture { redact.toggle() }
        }
    }
}
