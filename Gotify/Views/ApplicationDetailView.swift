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
    @AppStorage("notificationsActiveGlobal") var notificationsActiveGlobal = true

    init(application: Application) {
        self.application = application
    }

    var disabledDescription: String =
"""
Notifications are disabled globally and need to be enabled before changing application specific behavior.
"""

    var body: some View {
        List {
            Section(header: Text("Details"), footer: Text(notificationsActiveGlobal ? "" : disabledDescription)) {
                NavigationLink(destination: TextModify(fieldName: "Name", target: $application.nameValue)) {
                    KeyValueText(left: "Name", right: $application.nameValue)
                }
                NavigationLink(destination: TextModify(fieldName: "Description", target: $application.aboutValue)) {
                    KeyValueText(left: "Description", right: $application.aboutValue)
                }
                Toggle("Notifications", isOn: $application.notifyUser)
                    .disabled(!notificationsActiveGlobal)
            }

            Section(header: Text("Danger Zone")) {
                SensitiveText(left: "Token", right: application.token ?? "Unknown")
                Text("Delete Application")
                    .foregroundColor(.red)
                    .onTapGesture {
                        Task { await application.delete(context: context) }
                        dismiss()
                    }
            }
        }
        .navigationTitle(application.nameValue)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            Task { await application.put(context: context) }
        }
    }
}
