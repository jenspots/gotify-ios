//
//  ServerView.swift
//  Gotify
//
//  Created by Jens Pots on 01/07/2022.
//

import SwiftUI

struct ServerDetailView: View {
    @State var url: String = "127.0.0.1"
    @Environment(\.managedObjectContext) private var context

    @FetchRequest
    var users: FetchedResults<User>
    
    @FetchRequest
    var clients: FetchedResults<Client>
    
    @FetchRequest
    var applications: FetchedResults<Application>

    init() {
        _users = FetchRequest<User>(
            sortDescriptors: [NSSortDescriptor(keyPath: \User.name, ascending: true)],
            animation: .default
        )
        
        _clients = FetchRequest<Client>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Client.name, ascending: true)],
            animation: .default
        )
        
        _applications = FetchRequest<Application>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Application.name, ascending: true)],
            animation: .default
        )
    }
    
    var urlDescription: String =
"""
To guarantee a secure connection, HTTPS is required. Both IP addresses and domain names are accepted.
"""

    var body: some View {
        List {
            Section(header: Text("Configuration")) {
                NavigationLink(destination: TextModify(fieldName: "URL", value: $url, description: urlDescription)) {
                    KeyValueText(left: "URL", right: Server.shared.urlSansProtocol())
                }
                SensitiveText(left: "Token", right: Server.shared.token)
            }
            
            Section(header: Text("Users")) {
                ForEach(users) { user in
                    NavigationLink(destination: UserDetailView(user: user)) {
                        KeyValueText(left: user.nameValue, right: user.admin ? "Admin" : "")
                    }
                }
                .onDelete { indices in
                    indices.forEach { index in
                        Task { await users[index].delete(context: context) }
                    }
                }
            }
            
            Section(header: Text("Applications")) {
                ForEach(applications) { application in
                    NavigationLink(destination: ApplicationDetailView(application: application)) {
                        KeyValueText(left: application.nameValue, right: "")
                    }
                }
                .onDelete { indices in
                    indices.forEach { index in
                        Task { await applications[index].delete(context: context) }
                    }
                }
            }

            Section(header: Text("Clients")) {
                ForEach(clients) { client in
                    NavigationLink(destination: ClientDetailView(client: client)) {
                        Text(client.name!)
                    }
                }
                .onDelete { indices in
                    indices.forEach { index in
                        Task { await clients[index].delete(context: context) }
                    }
                }
            }

        }
        .navigationTitle(Server.shared.urlSansProtocol())
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            Task { await User.getAll(context: PersistenceController.shared.container.viewContext) }
            Task { await Client.getAll(context: PersistenceController.shared.container.viewContext) }
        }
    }
}

struct ServerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ServerDetailView()
        }
    }
}
