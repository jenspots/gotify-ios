//
//  TextModify.swift
//  Gotify
//
//  Created by Jens Pots on 05/07/2022.
//

import SwiftUI

struct TextModify: View {
    @FocusState private var focused: Bool

    let fieldName: String
    @Binding var value: String
    var description: String = ""

    var body: some View {
        List {
            Section(footer: Text(description)) {
                TextField(fieldName, text: $value)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .focused($focused)
                    .onAppear {
                          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                              focused = true
                          }
                    }
            }
        }
        .navigationTitle(fieldName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
