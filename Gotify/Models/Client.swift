//
//  Client.swift
//  Gotify
//
//  Created by Jens Pots on 05/07/2022.
//

import Foundation
import SwiftyJSON
import CoreData
import SwiftUI

public class Client: NSManagedObject, Serializable {

    var nameValue: String {
        get { name! }
        set { name = newValue }
    }

    static func new() -> Client {
        Client(entity: entity(), insertInto: nil)
    }

    // Serializeable
    func toJSON() -> JSON {
        JSON([
            "name": name!
        ])
    }

    // Serializeable
    static func fromJSON(json: JSON) -> Self {
        let result = Client.new()
        result.id = json["id"].int64!
        result.name = json["name"].string!
        result.token = json["token"].string!
        return result as! Self
    }

    /* Retrieve clients from the server. */
    static func getAll(context: NSManagedObjectContext) async -> GotifyError? {
        let (_, clients): (Int, [Client]?) = await API.request(
            slug: "/client",
            body: nil,
            method: .get
        )

        if let clients = clients {
            for client in clients {
                do {
                    let request = Client.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %d", client.id)
                    let queryResult = try context.fetch(request)

                    if queryResult.count > 2 {
                        fatalError("Core Data Error: uniqueness constrained broken")
                    }

                    if let queryResult = queryResult.first {
                        queryResult.name = client.name
                    } else {
                        context.insert(client)
                    }

                    DispatchQueue.main.async { try? context.save() }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }

        return nil
    }

    // Push edited client to the server
    func put(context: NSManagedObjectContext) async -> GotifyError? {
        let (_, _): (Int, Client?) = await API.request(
            slug: "/client/\(id)",
            body: self,
            method: .put
        )
        DispatchQueue.main.async { try? context.save() }
        return nil
    }

    // Delete client
    func delete(context: NSManagedObjectContext) async -> GotifyError? {
        let (_, _): (Int, Nil?) = await API.request(
            slug: "/client/\(id)",
            body: nil,
            method: .delete
        )

        context.delete(self)
        DispatchQueue.main.async { try? context.save() }

        return nil
    }

    func create(context: NSManagedObjectContext) async -> GotifyError? {
        let (_, client): (Int, Client?) = await API.request(
            slug: "/client",
            body: self,
            method: .post
        )

        if let client = client {
            context.insert(client)
            DispatchQueue.main.async { try? context.save() }
        } else {
            // IN ERROR
        }

        return nil
    }

    static func fetchAll() -> FetchRequest<Client> {
        FetchRequest<Client>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Client.name, ascending: true)],
            animation: .default
        )
    }

}
