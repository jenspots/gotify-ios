//
//  ClientRowComponent.swift
//  Gotify
//
//  Created by Jens Pots on 01/07/2022.
//

import SwiftUI

struct ClientRowComponent: View {
    @State var name: String
    @State var token: String

    var body: some View {
        NavigationLink(destination: ClientDetailView(name: name, token: token)) {
            Text(name)
        }
    }
}
