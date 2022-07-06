//
//  ServerView.swift
//  Gotify
//
//  Created by Jens Pots on 01/07/2022.
//

import SwiftUI

struct ServerDetailView: View {
    // We require the Core Data context to view and change objects
    @Environment(\.managedObjectContext) private var context

    // The server configuration
    @AppStorage("serverUrl") var serverUrl: String = ""
    @AppStorage("serverToken") var serverToken: String = ""

    // The data that will be shown in this view
    @FetchRequest var users: FetchedResults<User>
    @FetchRequest var clients: FetchedResults<Client>
    @FetchRequest var applications: FetchedResults<Application>

    // Temporary values to prevent writing to AppStorage directly
    @State var url: String = "something went wrong"
    @State var token: String = "something went wrong"

    // Sheet controllers
    @State var newClient: Bool = false
    @State var newApplication: Bool = false
    @State var newUser: Bool = false

    // Text components
    var urlDescription: String = "To guarantee a secure connection, HTTPS is required. Both IP addresses and domain names are accepted."
    var tokenDescription: String = "This application requires a client token to communicate with the server."

    init() {
        // Fetch requests
        _users = User.fetchAll()
        _clients = Client.fetchAll()
        _applications = Application.fetchAll()

        // Temporary values
        _url = State(wrappedValue: serverUrl)
        _token = State(wrappedValue: serverToken)
    }

    var body: some View {
        List {
            Section(header: Text("Configuration")) {
                NavigationLink(destination: TextModify(fieldName: "URL", value: $url, description: urlDescription).onDisappear { UserDefaults.standard.set(url, forKey: "serverUrl") }) {
                    KeyValueText(left: "URL", right: $serverUrl)
                }
                NavigationLink(destination: TextModify(fieldName: "Token", value: $token, description: tokenDescription).onDisappear { UserDefaults.standard.set(token, forKey: "serverToken") }) {
                    KeyValueText(left: "Token", right: $serverToken)
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
