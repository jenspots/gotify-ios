//
//  ClientNewView.swift
//  Gotify
//
//  Created by Jens Pots on 06/07/2022.
//

import SwiftUI

struct ClientNewView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var name: String = ""
    @Binding var isPresented: Bool

    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }

    func createClient() {
        let client = Client.new()
        client.name = name
        Task { await client.create(context: context) }
        isPresented = false
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Client Name"), footer: Text("This field is required")) {
                    TextField("Client Name", text: $name)
                }

                Section(footer: Button(action: createClient) {
                    Text("Create Client")
                }
                .font(.headline.weight(.medium))
                .tint(.blue)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                .frame(width: 500)
                .disabled(name.isEmpty)
                ) { EmptyView() }
            }
            .navigationBarTitle("New Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}
