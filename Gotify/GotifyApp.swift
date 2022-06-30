//
//  GotifyApp.swift
//  Gotify
//
//  Created by Jens Pots on 28/06/2022.
//

import SwiftUI

@main
struct GotifyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
