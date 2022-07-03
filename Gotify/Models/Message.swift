//
//  MessageModel+CoreDataClass.swift
//  Gotify
//
//  Created by Jens Pots on 30/06/2022.
//
//

import Alamofire
import SwiftyJSON
import CoreData

private class PaginatedMessages: Serializeable {
    
    fileprivate let messages: [Message]
    fileprivate let paging: Paging
    
    init(messages: [Message], paging: Paging) {
        self.messages = messages
        self.paging = paging
    }
    
    static func fromJSON(json: JSON) -> Self {
        let messages = Array<Message>.fromJSON(json: json["messages"])
        let paging = Paging.fromJSON(json: json["paging"])
        return PaginatedMessages(messages: messages, paging: paging) as! Self
    }
    
    func toJSON() -> JSON {
        var result = JSON()
        result["messages"] = messages.toJSON()
        result["paging"] = paging.toJSON()
        return result
    }
    
}

public class Message: NSManagedObject, Serializeable {
    
    // Required for the fromJSON function.
    static let dateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.locale = Locale(identifier: "en_US_POSIX")
        result.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return result
    }()

    // Serializable
    static func fromJSON(json: JSON) -> Self {
        let result = Message(context: PersistenceController.shared.container.viewContext)
        result.id = json["id"].int64!
        result.appid = json["appid"].int64!
        result.date = Message.dateFormatter.date(from: json["date"].string!)!
        result.message = json["message"].string
        result.priority = json["priority"].int64 ?? 0
        result.title = json["title"].string
        return result as! Self
    }
    
    // Serializable
    func toJSON() -> JSON {
        return JSON([
            "message": self.message ?? "",
            "priority": self.priority,
            "title": self.title ?? ""
        ])
    }

    func delete(context: NSManagedObjectContext) async -> GotifyError? {
        // The object will be removed, so we need to keep a copy of the id
        let id = self.id
        
        // Remove the object in the background
        DispatchQueue.main.async {
            context.delete(self)
            try? context.save()
        }

        // Make the request
        let (status, _): (Int, Message?) = await API.request(
            slug: "/message/\(id)",
            body: nil,
            method: .delete
        )
        
        if status != 200 {
            // TODO: notify of error and restore object
        }

        return nil
    }
    
    func put(context: NSManagedObjectContext) async -> GotifyError? {
        let (_, _): (Int, Message?) = await API.request(
            slug: "/message/\(id)",
            body: self,
            method: .put
        )
        DispatchQueue.main.async{ try? context.save() }
        return nil
    }
    
    /* Retrieve new Applications from the server. */
    static func getAll(context: NSManagedObjectContext, application: Application? = nil) async -> GotifyError? {
        var slug: String
        if let application = application {
            slug = "/application/\(application.id)/message/"
        } else {
            slug = "message/"
        }

        let (_, _): (Int, PaginatedMessages?) = await API.request(
            slug: slug,
            body: nil,
            method: .get
        )
        DispatchQueue.main.async{ try? context.save() }
        return nil
    }
    
}
