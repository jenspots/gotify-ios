//
//  ServerView.swift
//  Gotify
//
//  Created by Jens Pots on 01/07/2022.
//

import SwiftUI

struct ServerDetailView: View {
    @Environment(\.managedObjectContext)
    private var context

    @FetchRequest
    var users: FetchedResults<User>
    
    @FetchRequest
    var clients: FetchedResults<Client>
    
    @FetchRequest
    var applications: FetchedResults<Application>

    @State
    var url: String = "127.0.0.1"
    
    @State
    var token: String = "secret-token"
    
    @State
    var newClient: Bool = false
    
    @State
    var newApplication: Bool = false

    @State
    var newUser: Bool = false

    @State
    var genericString1: String = ""
    
    @State
    var genericString2: String = ""
    
    @State
    var genericToggle1: Bool = false

    var urlDescription: String = "To guarantee a secure connection, HTTPS is required. Both IP addresses and domain names are accepted."
    var tokenDescription: String = "This application requires a client token to communicate with the server."

    init() {
        _users = User.fetchAll()
        _clients = Client.fetchAll()
        _applications = Application.fetchAll()
    }

    var body: some View {
        List {
            Section(header: Text("Configuration")) {
                NavigationLink(destination: TextModify(fieldName: "URL", value: $url, description: urlDescription)) {
                    KeyValueText(left: "URL", right: Server.shared.urlSansProtocol())
                }
                NavigationLink(destination: TextModify(fieldName: "Token", value: $token, description: tokenDescription)) {
                    SensitiveText(left: "Token", right: Server.shared.token)
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
                
                Button(action: { newApplication.toggle() }) {
                    Text("New Application")
                }
                .foregroundColor(.gray)
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
                
                Button(action: { newClient.toggle() }) {
                    Text("New Client")
                }
                .foregroundColor(.gray)
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
                
                Button(action: { newUser.toggle() }) {
                    Text("New User")
                }
                .foregroundColor(.gray)

            }
        }
        .navigationTitle(Server.shared.urlSansProtocol())
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            Task { await User.getAll(context: PersistenceController.shared.container.viewContext) }
            Task { await Client.getAll(context: PersistenceController.shared.container.viewContext) }
        }
        .sheet(isPresented: $newClient) {
            ClientNewView(isPresented: $newClient)
        }
        .sheet(isPresented: $newUser) {
            UserNewView(isPresented: $newUser)
        }
        .sheet(isPresented: $newApplication) {
            ApplicationNewView(isPresented: $newApplication)
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
