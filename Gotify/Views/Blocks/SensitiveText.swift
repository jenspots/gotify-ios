//
//  SensitiveText.swift
//  Gotify
//
//  Created by Jens Pots on 01/07/2022.
//

import SwiftUI

struct SensitiveText: View {
    var text: String
    @State var redact: Bool = true
    
    var body: some View {
        HStack {
            Text(text)
                .redacted(reason: redact ? .placeholder : .privacy)
            Spacer()
            Image(systemName: redact ? "eye" : "eye.slash")
                .foregroundColor(.gray)
                .onTapGesture { redact.toggle() }
        }
    }
}
