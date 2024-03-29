//
//  HomeView.swift
//  Gotify
//
//  Created by Jens Pots on 28/06/2022.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("serverUrl") var serverUrl: String = ""
    @AppStorage("serverToken") var serverToken: String = ""
    @Environment(\.managedObjectContext) private var context
    @Binding var noConfigurationSet: Bool

    init() {
        _noConfigurationSet = Binding(get: {
            if let serverUrl = UserDefaults.standard.string(forKey: "serverUrl") {
                if let serverToken = UserDefaults.standard.string(forKey: "serverToken") {
                    return serverUrl.isEmpty || serverToken.isEmpty
                }
            }
            return true
        }, set: { _ in
            // do nothing
        })
    }

    var body: some View {
        TabView {
            ApplicationListView()
                .tabItem {
                    Label("Applications", systemImage: "antenna.radiowaves.left.and.right")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .sheet(isPresented: $noConfigurationSet) { WelcomeView(url: serverUrl, token: serverToken) }
        .task { await Application.getAll(context: context) }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
