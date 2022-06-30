//
//  SettingsView.swift
//  Gotify
//
//  Created by Jens Pots on 30/06/2022.
//

import CoreData
import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var allNotifications: Bool = true
    @State var serverUrl: String = ""

    private var values: [String: String] {
        let request: NSFetchRequest<KeyValues> = KeyValues.fetchRequest()
        var result: [String: String] = [:]
        guard let entries = try? viewContext.fetch(request)
        else {
            return result
        }

        for entry in entries {
            result[entry.key!] = entry.value!
        }

        return result
    }

    @State var newtoken: String = ""

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("General")) {
                    Toggle(isOn: $allNotifications) {
                        Text("All Notifications")
                    }
                }

                Section(header: Text("Server Settings")) {
                    HStack {
                        Text("Server URL")
                        TextField(values["server_url"] ?? "Add", text: $serverUrl)
                            .textFieldStyle(.plain)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Token")
                        TextField(values["user_token"] ?? "Add", text: $newtoken)
                            .textFieldStyle(.plain)
                            .multilineTextAlignment(.trailing)
                    }

                    Text("Verify Connection")
                        .foregroundColor(.blue)
                }

                Section(header: Text("Get Help")) {
                    NavigationLink(destination: {}) {
                        Text("Frequently Asked Questions")
                    }

                    NavigationLink(destination: {}) {
                        Text("Contact")
                    }

                    NavigationLink(destination: {}) {
                        Text("Logs")
                    }
                }

                Section(header: Text("About")) {
                    NavigationLink(destination: {}) {
                        Text("Developer")
                    }

                    NavigationLink(destination: {}) {
                        Text("Acknowledgements")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
