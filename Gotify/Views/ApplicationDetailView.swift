//
//  ApplicationDetailView.swift
//  Gotify
//
//  Created by Jens Pots on 05/07/2022.
//

import SwiftUI

struct ApplicationDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var context

    @ObservedObject var application: Application
    @AppStorage("notificationsActiveGlobal") var notificationsActiveGlobal: Bool = true
    @State var newName: String
    
    init(application: Application) {
        self.application = application
        self._newName = State(initialValue: String(application.nameValue))
    }
    
    var disabledDescription: String =
"""
Notifications are disabled globally and need to be enabled before changing application specific behavior.
"""
    
    var body: some View {
        List {
            Section(header: Text("Details"), footer: Text(notificationsActiveGlobal ? "" : disabledDescription)) {
                NavigationLink(destination: TextModify(fieldName: "Name", value: $newName)) {
                    KeyValueText(left: "Name", right: $newName)
                }
                Toggle("Notifications", isOn: $application.notifyUser)
                    .disabled(!notificationsActiveGlobal)
            }

            Section(header: Text("Danger Zone")) {
                SensitiveText(left: "Token", right: application.token!)
                Text("Delete Application")
                    .foregroundColor(.red)
                    .onTapGesture {
                        // TODO: DELETE REQUEST
                        Task { await application.delete(context: context) }
                        dismiss()
                    }
            }
        }
        .navigationTitle(application.nameValue)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            application.name = newName
            Task { await application.put(context: context) }
            // TODO: PUT REQUEST
        }
    }
}

