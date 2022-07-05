//
//  Client.swift
//  Gotify
//
//  Created by Jens Pots on 05/07/2022.
//

import Foundation
import SwiftyJSON
import CoreData

public class Client: NSManagedObject, Serializeable {
    
    var nameValue: String {
        get { return self.name! }
        set { self.name = newValue }
    }
        
    // Serializeable
    func toJSON() -> JSON {
        return JSON([
            "name": self.name!
        ])
    }
    
    // Serializeable
    static func fromJSON(json: JSON) -> Self {
        let result = Client(context: PersistenceController.shared.container.viewContext)
        result.id = json["id"].int64!
        result.name = json["name"].string!
        result.token = json["token"].string!
        return result as! Self
    }

    /* Retrieve clients from the server. */
    static func getAll(context: NSManagedObjectContext) async -> GotifyError? {
        let (_, _): (Int, [Client]?) = await API.request(
            slug: "/client",
            body: nil,
            method: .get
        )
        DispatchQueue.main.async{ try? context.save() }
        return nil
    }
    
    // Push edited client to the server
    func put(context: NSManagedObjectContext) async -> GotifyError? {
        let (_, _): (Int, Client?) = await API.request(
            slug: "/client/\(self.id)",
            body: self,
            method: .put
        )
        DispatchQueue.main.async{ try? context.save() }
        return nil
    }

    // Delete client
    func delete(context: NSManagedObjectContext) async -> GotifyError? {
        let (_, _): (Int, Nil?) = await API.request(
            slug: "/client/\(self.id)",
            body: nil,
            method: .delete
        )
        
        context.delete(self)
        DispatchQueue.main.async { try? context.save() }

        return nil
    }

}
