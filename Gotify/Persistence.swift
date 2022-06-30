//
//  Persistence.swift
//  Gotify
//
//  Created by Jens Pots on 28/06/2022.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    /* Generate dummy data for use in Xcode Preview. */
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        /* An application */
        let app = ApplicationModel(context: viewContext)
        app.id = 0
        app.token = "secret-token"
        app.image = "mascott"
        app.name = "My Application"
        app.about = "This is a dummy value"
        app.notifyUser = true

        /* Messages */
        for i in 0..<10 {
            let message = MessageModel(context: viewContext)
            message.id = Int64(i)
            message.message = "This is a dummy message"
            message.title = "Message Received"
            message.appid = 0
            message.date = .now
            message.priority = 0
        }

        let server = KeyValues(context: viewContext)
        server.key = "server_url"
        server.value = "127.0.0.1"

        let token = KeyValues(context: viewContext)
        token.key = "user_token"
        token.value = "very-secret-token"

        /* Attempt to save to temporary store. */
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return result
    }()

    init(inMemory: Bool = false) {
        /* Initialize container. */
        container = NSPersistentCloudKitContainer(name: "Gotify")

        /* For development purposes. */
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        /* Allows overwriting when identifiers match. */
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        /* Initialize. */
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)") // TODO
            }
        }

        /* Autogenerated. Probably important. */
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
