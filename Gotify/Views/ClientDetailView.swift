//
//  ClientDetailView.swift
//  Gotify
//
//  Created by Jens Pots on 02/07/2022.
//

import SwiftUI

struct ClientDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var context

    @ObservedObject var client: Client

    init(client: Client) {
        self.client = client
    }

    var body: some View {
        List {
            Section(header: Text("Details")) {
                NavigationLink(destination: TextModify(fieldName: "Name", target: $client.nameValue)) {
                    KeyValueText(left: "Name", right: $client.nameValue)
                }
            }

            Section(header: Text("Danger Zone")) {
                SensitiveText(left: "Token", right: client.token!)
                Text("Delete Client")
                    .foregroundColor(.red)
                    .onTapGesture {
                        Task { await client.delete(context: context) } 
                        dismiss()
                    }
            }
        }
        .navigationTitle(client.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            Task { await client.put(context: context) }
        }
    }
}
