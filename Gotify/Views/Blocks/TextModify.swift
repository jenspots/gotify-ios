//
//  TextModify.swift
//  Gotify
//
//  Created by Jens Pots on 05/07/2022.
//

import SwiftUI

struct TextModify: View {
    // Pop up keyboard automatically
    @FocusState private var focused: Bool

    // Main contents
    let fieldName: String
    @State var temp: String
    @Binding var target: String
    var hidden: Bool

    // Shown as the section's footer
    var description: String

    init(fieldName: String, target: Binding<String>, description: String = "", hidden: Bool = false) {
        self.fieldName = fieldName
        self._target = target
        self.description = description
        self._temp = State(initialValue: target.wrappedValue)
        self.hidden = hidden
    }

    var body: some View {
        List {
            Section(footer: Text(description)) {
                if hidden {
                    SecureField(fieldName, text: $temp)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($focused)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                focused = true
                            }
                        }
                } else {
                    TextField(fieldName, text: $temp)
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
        }
        .navigationTitle(fieldName)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            if temp != "" {
                target = temp
            }
        }
    }
}
