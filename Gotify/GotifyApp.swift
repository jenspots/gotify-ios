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
    
    init() {
        Task { await Application.getAll(context: PersistenceController.shared.container.viewContext) }
        Task { await Message.getAll(context: PersistenceController.shared.container.viewContext) }
        Task { await User.getAll(context: PersistenceController.shared.container.viewContext) }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
