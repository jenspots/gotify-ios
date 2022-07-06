//
//  ApplicationNewView.swift
//  Gotify
//
//  Created by Jens Pots on 06/07/2022.
//

import SwiftUI

struct ApplicationNewView: View {

    @Environment(\.managedObjectContext) private var context
    @State private var name: String = ""
    @State private var description: String = ""
    @Binding var isPresented: Bool

    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }

    func createApplication() {
        let application = Application.new()
        application.name = name
        application.about = description
        Task { await application.create(context: context) }
        isPresented = false
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Name")) {
                    TextField("Application", text: $name)
                }

                Section(header: Text("Description")) {
                    TextField("Description", text: $description)
                }

                Section(footer: Button(action: createApplication) {
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
                    Button(action: { isPresented = false }) {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}
