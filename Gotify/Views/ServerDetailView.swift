//
//  ServerView.swift
//  Gotify
//
//  Created by Jens Pots on 01/07/2022.
//

import SwiftUI

struct ServerDetailView: View {
    @State var url: String = "127.0.0.1"

    var body: some View {
        List {
            Section(header: Text("Configuration")) {
                HStack {
                    Text("URL")
                    TextField("Server URL", text: $url)
                        .multilineTextAlignment(.trailing)
                }
                SensitiveText(text: "very-secret-token")
            }
            
            Section(header: Text("Users")) {
                UserRowComponent(userName: "Greg", admin: true)
                UserRowComponent(userName: "Jake", admin: false)
                UserRowComponent(userName: "Duke", admin: true)

            }
            Section(header: Text("Clients")) {
                ClientRowComponent(name: "Safari", token: "secret-token")
            }

        }
        .navigationTitle("gotify.com")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ServerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ServerDetailView()
        }
    }
}
