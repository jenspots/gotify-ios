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

    @Binding var noConfigurationSet: Bool

    init() {
        _noConfigurationSet = Binding(get: {
            if let serverUrl = UserDefaults.standard.string(forKey: "serverUrl") {
                if let serverToken = UserDefaults.standard.string(forKey: "serverToken") {
                    return serverUrl == "" || serverToken == ""
                }
            }
            return true
        }, set: { x in
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
