//
//  UserDetailView.swift
//  Gotify
//
//  Created by Jens Pots on 05/07/2022.
//

import SwiftUI

struct UserDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var context

    @ObservedObject var user: User

    init(user: User) {
        self.user = user
    }

    var body: some View {
        List {
            Section(header: Text("Details")) {
                NavigationLink(destination: TextModify(fieldName: "Username", target: $user.nameValue)) {
                    KeyValueText(left: "Name", right: $user.nameValue)
                }
                Toggle("Admin", isOn: $user.admin)
            }

            Section(header: Text("Danger Zone")) {
                NavigationLink(destination: TextModify(fieldName: "Password", target: $user.password, hidden: true)) {
                    Text("New Password")
                }

                Text("Delete User")
                    .foregroundColor(.red)
                    .onTapGesture {
                        // TODO: DELETE REQUEST
                        dismiss()
                    }
            }
        }
        .navigationTitle(user.nameValue)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { Task { await user.put(context: context) } }
    }
}
