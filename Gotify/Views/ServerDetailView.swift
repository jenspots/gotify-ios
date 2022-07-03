//
//  ServerView.swift
//  Gotify
//
//  Created by Jens Pots on 01/07/2022.
//

import SwiftUI

struct ServerDetailView: View {
    @State var url: String = "127.0.0.1"
    
    @FetchRequest
    var users: FetchedResults<User>
    
    init() {
        _users = FetchRequest<User>(
            sortDescriptors: [NSSortDescriptor(keyPath: \User.name, ascending: false)],
            animation: .default
        )
    }

    var body: some View {
        List {
            Section(header: Text("Configuration")) {
                NavigationLink(destination: {}) {
                    KeyValueText(left: "URL", right: Server.shared.urlSansProtocol())
                }
                SensitiveText(left: "Token", right: Server.shared.token)
            }
            
            Section(header: Text("Users")) {
                ForEach(users) { user in
                    UserRowComponent(user: user)
                }
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
