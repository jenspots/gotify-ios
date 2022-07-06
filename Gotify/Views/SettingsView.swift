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
    @AppStorage("notificationsActiveGlobal") var notificationsActiveGlobal: Bool = true

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

                Section(header: Text("About"), footer: HStack {
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

                Section(header: Text("Danger Zone")) {
                    Button(action: {
                        // Delete local AppStorage
                        UserDefaults.standard.removeObject(forKey: "serverUrl")
                        UserDefaults.standard.removeObject(forKey: "serverToken")

                        // Remove CoreData storage
                        // TODO
                    }) {
                        Text("Reset App")
                                .foregroundColor(.red)
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
