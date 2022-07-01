//
//  HomeView.swift
//  Gotify
//
//  Created by Jens Pots on 28/06/2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ApplicationListView()
            .tabItem { Label("Applications", systemImage: "antenna.radiowaves.left.and.right") }
            
            SettingsView()
            .tabItem { Label("Settings", systemImage: "gear")}
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
