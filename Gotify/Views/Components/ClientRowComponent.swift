//
//  ClientRowComponent.swift
//  Gotify
//
//  Created by Jens Pots on 01/07/2022.
//

import SwiftUI

struct ClientDetailView: View {
    @State var name: String
    @State var token: String

    var body: some View {
        List {
            Text(name)
            SensitiveText(text: token)
            Text("Delete")
                .foregroundColor(.red)
        }
    }
}

struct ClientRowComponent: View {
    @State var name: String
    @State var token: String

    var body: some View {
        NavigationLink(destination: ClientDetailView(name: name, token: token)) {
            Text(name)
        }
    }
}
