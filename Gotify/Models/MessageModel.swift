//
//  MessageModel+CoreDataClass.swift
//  Gotify
//
//  Created by Jens Pots on 30/06/2022.
//
//

import Alamofire
import Foundation
import CoreData

public class MessageModel: NSManagedObject {
    private struct Message: Codable {
        var id: Int64
        var appid: Int64
        var date: Date
        var message: String
        var priority: Int64?
        var title: String?
        
        init(id: Int64, appid: Int64, date: Date, message: String, priority: Int64, title: String) {
            self.id = id
            self.appid = appid
            self.date = date
            self.message = message
            self.priority = priority
            self.title = title
        }
    }
    
    private static func fromMessage(context: NSManagedObjectContext, message: Message) -> MessageModel {
        let newMessage = MessageModel(context: context)
        newMessage.id = message.id
        newMessage.appid = message.appid
        newMessage.date = message.date
        newMessage.message = message.message
        newMessage.priority = message.priority ?? 0
        newMessage.title = message.title
        return newMessage
    }
    
    private func toMessage() -> Message {
        Message(
            id: id,
            appid: appid,
            date: date ?? .now,
            message: message ?? "",
            priority: self.priority,
            title: self.title ?? ""
        )
    }
    
    func delete() async -> GotifyError? {
        print("Deleting message \(self.id)")
        let url = "\(Server.shared.serverUrl)/message/\(id)"

        print("REQUEST: DELETE \(url)")
        if let statusCode = await AF.request(url, method: .delete, headers: Server.shared.headers).serializingData().response.response?.statusCode {
            print("Deleting message: response \(statusCode)")
            return nil
        } else {
            print("Deleting message: server error")
            return GotifyError.unknown()
        }
    }
    
    /* Retrieve new Applications from the server. */
    static func refresh(context: NSManagedObjectContext, application: ApplicationModel) async -> GotifyError? {
        // Decoder we're gonna use
        let decoder: JSONDecoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        print("Retrieving messages for app \(application.id)")
        
        // TODO: all messages, not for one application
        let url = Server.shared.serverUrl + "/application/\(application.id)/message"

        // Retrieve data
        guard let data = try? await AF.request(url, headers: Server.shared.headers).serializingData().value else {
            return GotifyError.unknown()
        }
        
        // The structure of the data returned from the server, for decoding purposes
        struct PaginatedMessages: Codable {
            var messages: [Message]
            var paging: Paging
        }
        
        // In case of a server error
        if let result = try? decoder.decode(GotifyError.self, from: data) {
            return result
        }

        // In case of success
        guard let result = try? decoder.decode(PaginatedMessages.self, from: data) else {
            return GotifyError.unknown()
        }
        
        print("Retrieved messages succesfully")
        var toAdd: [MessageModel] = []
        for message in result.messages {
            toAdd.append(MessageModel.fromMessage(context: context, message: message))
        }

        DispatchQueue.main.async {
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
                            
        return nil
    }

}
