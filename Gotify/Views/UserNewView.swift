//
//  UserNewView.swift
//  Gotify
//
//  Created by Jens Pots on 06/07/2022.
//

import SwiftUI

struct UserNewView: View {

    @Environment(\.managedObjectContext) private var context
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var admin: Bool = false
    @Binding var isPresented: Bool

    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }

    func createUser() {
        let user = User.new()
        user.name = username
        user.password = password
        user.admin = admin
        Task { await user.create(context: context) }
        isPresented = false // dismisses view
    }

    var body: some View {
        NavigationView() {
            List {
                Section(header: Text("Username"), footer: Text("This field is required")) {
                    TextField("Username", text: $username)
                }

                Section(header: Text("Password"), footer: Text("This field is required")) {
                    TextField("Password", text: $password)
                }

                Section(header: Text("Privileges")) {
                    Toggle(isOn: $admin) { Text("Administrator") }
                }

                Section(footer: Button(action: createUser) {
                    Text("Create User")
                }
                .font(.headline.weight(.medium))
                .tint(.blue)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                .frame(width: 500)
                .disabled(username == "" || password == "")
                ) { EmptyView() }
            }
            .navigationBarTitle("New User")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isPresented = false }) {
                        Text("Cancel")
                    }
                }
            }
        }

    }
}
