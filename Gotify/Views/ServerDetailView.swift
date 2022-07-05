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
        .sheet(isPresented: $newClient, onDismiss: {
            genericString1 = ""
        }) {
            NavigationView() {
                List {
                    Section(header: Text("Client Name")) {
                        TextField("Client Name", text: $genericString1)
                    }
                                        
                    Section(footer: Button(action: {
                        let client = Client.new()
                        client.name = genericString1
                        Task { await client.create(context: context) }
                        newClient.toggle()
                    }) {
                            Text("Create Client")
                        }
                        .font(.headline.weight(.medium))
                        .tint(.blue)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .controlSize(.large)
                        .frame(width: 500)
                        
                    ) { EmptyView() }
                }
                .navigationBarTitle("New Client")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            genericString1 = ""
                            genericString2 = ""
                            newClient = false
                        }) {
                            Text("Cancel")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $newUser, onDismiss: {
            genericString1 = ""
            genericString2 = ""
            genericToggle1 = false
        }) {
            NavigationView() {
                List {
                    Section(header: Text("Username")) {
                        TextField("Username", text: $genericString1)
                    }
                    
                    Section(header: Text("Password")) {
                        TextField("Password", text: $genericString2)
                    }
                    
                    Section(header: Text("Privileges")) {
                        Toggle(isOn: $genericToggle1) { Text("Administrator") }
                    }
                    
                    Section(footer: Button(action: {
                        let user = User.new()
                        user.name = genericString1
                        user.password = genericString2
                        Task { await user.create(context: context) }
                        newUser.toggle()
                    }) {
                            Text("Create User")
                        }
                        .font(.headline.weight(.medium))
                        .tint(.blue)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .controlSize(.large)
                        .frame(width: 500)
                        
                    ) { EmptyView() }
                }
                .navigationBarTitle("New User")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            genericString1 = ""
                            genericString2 = ""
                            newUser = false
                        }) {
                            Text("Cancel")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $newApplication, onDismiss: {
            genericString1 = ""
            genericString2 = ""
        }) {
            NavigationView() {
                List {
                    Section(header: Text("Name")) {
                        TextField("Application", text: $genericString1)
                    }
                    
                    Section(header: Text("Description")) {
                        TextField("Description", text: $genericString2)
                    }
                    
                    Section(footer: Button(action: {
                        let application = Application.new()
                        application.name = genericString1
                        application.about = genericString2
                        Task { await application.create(context: context) }
                        newApplication.toggle()
                    }) {
                            Text("Create Application")
                        }
                        .font(.headline.weight(.medium))
                        .tint(.blue)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .controlSize(.large)
                        .frame(width: 500)
                        
                    ) { EmptyView() }
                }
                .navigationBarTitle("New Application")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            genericString1 = ""
                            genericString2 = ""
                            newApplication = false
                        }) {
                            Text("Cancel")
                        }
                    }
                }
            }
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
