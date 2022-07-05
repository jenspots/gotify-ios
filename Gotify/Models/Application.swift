//
//  ApplicationModel+CoreDataClass.swift
//  Gotify
//
//  Created by Jens Pots on 30/06/2022.
//
//

import Alamofire
import CoreData
import SwiftyJSON
import Foundation

public final class Application: NSManagedObject, Serializeable {
    
    var slug: String {
        get { return "/application/\(id)" }
    }
    
    var nameValue: String {
        get { return self.name! }
        set { self.name = newValue }
    }
    
    // Serializable
    static func fromJSON(json: JSON) -> Self {
        let result = Application(context: PersistenceController.shared.container.viewContext)
        result.id = json["id"].int64!
        result.token = json["token"].string
        result.name = json["name"].string
        result.image = json["image"].string
        result.about = json["description"].string
        return result as! Self
    }
   
    // Serializable
    func toJSON() -> JSON {
        return JSON([
            "id": id,
            "name": name ?? "",
            "description": about ?? ""
        ])
    }
    
    // Delete an application form the server, then from memory.
    func delete(context: NSManagedObjectContext) async -> GotifyError? {
        let (_, _): (Int, Nil?) = await API.request(
            slug: "/application/\(self.id)",
            body: nil,
            method: .delete
        )
        
        context.delete(self)
        DispatchQueue.main.async { try? context.save() }

        return nil
    }

    func put(context: NSManagedObjectContext) async -> GotifyError? {
        let (_, _): (Int, Application?) = await API.request(
            slug: "/application/\(id)",
            body: self,
            method: .put
        )
        DispatchQueue.main.async{ try? context.save() }
        return nil
    }

    /* Retrieve new Applications from the server. */
    static func getAll(context: NSManagedObjectContext) async -> GotifyError? {
        let (_, _): (Int, [Application]?) = await API.request(
            slug: "/application",
            body: nil,
            method: .get
        )
        DispatchQueue.main.async{ try? context.save() }
        return nil
    }
}
