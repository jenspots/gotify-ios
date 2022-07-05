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
    @State var serverUrl: String = ""
    
    @AppStorage("notificationsActiveGlobal") var notificationsActiveGlobal: Bool = true

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
    
    var footerText: String =
"""
Disable this setting to receive no notifications whatsoever. This overrides application specific settings until turned off.
"""

    var body: some View {
        NavigationView {
            List {
                Section {
                    ServerRowComponent(server: .shared)
                }
                
                Section(header: Text("General"), footer: Text(footerText)) {
                    Toggle(isOn: $notificationsActiveGlobal) {
                        Text("All Notifications")
                    }
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

                Section(header: Text("About"), footer: HStack() {
                    Spacer()
                    VStack(spacing: 5) {
                        Text("Version 1.0.0")
                        Text("Build ae9512b6")
                    }
                    .padding(.top, 10)
                    Spacer()
                }) {
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
