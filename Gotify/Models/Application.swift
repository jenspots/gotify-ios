//
//  ApplicationModel+CoreDataClass.swift
//  Gotify
//
//  Created by Jens Pots on 30/06/2022.
//
//

import CoreData
import SwiftyJSON
import Foundation
import SwiftUI

public final class Application: NSManagedObject, Serializable {

    var slug: String {
        get { "/application/\(id)" }
    }

    static func new() -> Application {
        Application(entity: entity(), insertInto: nil)
    }

    var nameValue: String {
        get { name! }
        set { name = newValue }
    }

    var aboutValue: String {
        get { about! }
        set { about = newValue }
    }

    // Serializable
    static func fromJSON(json: JSON) -> Self {
        let result = Application.new()
        result.id = json["id"].int64!
        result.token = json["token"].string
        result.name = json["name"].string
        result.image = json["image"].string
        result.about = json["description"].string
        return result as! Self
    }

    // Serializable
    func toJSON() -> JSON {
        JSON([
            "id": id,
            "name": name ?? "",
            "description": about ?? ""
        ])
    }

    // Delete an application form the server, then from memory.
    func delete(context: NSManagedObjectContext) async -> GotifyError? {
        let (_, _): (Int, Nil?) = await API.request(
            slug: "/application/\(id)",
            body: nil,
            method: .delete
        )

        context.delete(self)
        DispatchQueue.main.async { try? context.save() }

        return nil
    }

    func put(context: NSManagedObjectContext) async -> GotifyError? {
        guard self.hasPersistentChangedValues else {
            return nil
        }

        let (_, _): (Int, Application?) = await API.request(
            slug: "/application/\(id)",
            body: self,
            method: .put
        )
        DispatchQueue.main.async { try? context.save() }
        return nil
    }

    /* Retrieve new Applications from the server. */
    static func getAll(context: NSManagedObjectContext) async -> GotifyError? {
        let (_, applications): (Int, [Application]?) = await API.request(
            slug: "/application",
            body: nil,
            method: .get
        )

        if let applications = applications {
            for application in applications {
                do {
                    let request = Application.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %d", application.id)
                    let queryResult = try context.fetch(request)

                    if queryResult.count > 2 {
                        fatalError("Core Data Error: uniqueness constrained broken")
                    }

                    if let queryResult = queryResult.first {
                        queryResult.name = application.name
                        queryResult.about = application.about
                    } else {
                        context.insert(application)
                    }

                    DispatchQueue.main.async { try? context.save() }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }

        return nil
    }

    func create(context: NSManagedObjectContext) async -> GotifyError? {
        let (_, application): (Int, Application?) = await API.request(
            slug: "/application",
            body: self,
            method: .post
        )

        if let application = application {
            context.insert(application)
            DispatchQueue.main.async { try? context.save() }
        } else {
            // IN ERROR
        }

        return nil
    }

    static func fetchAll() -> FetchRequest<Application> {
        FetchRequest<Application>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Application.name, ascending: true)],
            animation: .default
        )
    }
}
