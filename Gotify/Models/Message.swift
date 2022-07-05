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
    
    static func new() -> Message {
        return Message(entity: entity(), insertInto: nil)
    }
    
    // Required for the fromJSON function.
    static let dateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.locale = Locale(identifier: "en_US_POSIX")
        result.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return result
    }()

    // Serializable
    static func fromJSON(json: JSON) -> Self {
        let result = Message.new()
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
        do {
            try self.validateForDelete()
        } catch {
            print(error.localizedDescription)
            return nil
        }

        context.delete(self)
        
        // Make the request
        let (status, _): (Int, Nil?) = await API.request(
            slug: "/message/\(id)",
            body: nil,
            method: .delete
        )
        
        if status == 200 {
            DispatchQueue.main.async {
                do {
                    try context.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }

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

        let (_, paginatedMessages): (Int, PaginatedMessages?) = await API.request(
            slug: slug,
            body: nil,
            method: .get
        )
        
        if let messages = paginatedMessages?.messages {
            for message in messages {
                do {
                    let request = Message.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %d", message.id)
                    let queryResult = try context.fetch(request)
                    
                    if queryResult.count > 2 {
                        fatalError("Core Data Error: uniqueness constrained broken")
                    }
                    
                    // Note: messages cant be updated, so we just check if it exists locally.
                    if queryResult.first == nil {
                        context.insert(message)
                    }
                                        
                    DispatchQueue.main.async { try? context.save() }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }

        DispatchQueue.main.async{ try? context.save() }
        return nil
    }
    
}
