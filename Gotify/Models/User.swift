//
//  User+CoreDataClass.swift
//  Gotify
//
//  Created by Jens Pots on 03/07/2022.
//
//

import Foundation
import SwiftyJSON
import CoreData
import SwiftUI

public class User: NSManagedObject, Serializeable {
    
    var password: String? = nil

    var nameValue: String {
        get { return self.name! }
        set { self.name = newValue }
    }
    
    static func new() -> User {
        return User(context: PersistenceController.shared.container.viewContext)
    }
        
    // Serializeable
    func toJSON() -> JSON {
        var result = JSON([
            "admin": self.admin,
            "name": self.name!
        ])
        
        if let password = password {
            result["pass"] = JSON(stringLiteral: password)
        }
        
        return result
    }
    
    // Serializeable
    static func fromJSON(json: JSON) -> Self {
        let result = User(context: PersistenceController.shared.container.viewContext)
        result.id = json["id"].int64!
        result.admin = json["admin"].bool ?? false
        result.name = json["name"].string!
        return result as! Self
    }

    /* Retrieve new users from the server. */
    static func getAll(context: NSManagedObjectContext) async -> GotifyError? {
        let (_, _): (Int, [User]?) = await API.request(
            slug: "/user",
            body: nil,
            method: .get
        )
        DispatchQueue.main.async{ try? context.save() }
        return nil
    }
    
    // Push edited user to the server
    func put(context: NSManagedObjectContext) async -> GotifyError? {
        let (_, _): (Int, User?) = await API.request(
            slug: "/user/\(self.id)",
            body: self,
            method: .post
        )
        DispatchQueue.main.async{ try? context.save() }
        return nil
    }
    
    // Delete client
    func delete(context: NSManagedObjectContext) async -> GotifyError? {
        let (_, _): (Int, Nil?) = await API.request(
            slug: "/user/\(self.id)",
            body: nil,
            method: .delete
        )
        
        context.delete(self)
        DispatchQueue.main.async { try? context.save() }

        return nil
    }
    
    static func fetchAll() -> FetchRequest<User> {
        return FetchRequest<User>(
            sortDescriptors: [NSSortDescriptor(keyPath: \User.name, ascending: true)],
            animation: .default
        )
    }
    
    func create(context: NSManagedObjectContext) async -> GotifyError? {
        let (_, user): (Int, User?) = await API.request(
            slug: "/user",
            body: self,
            method: .post
        )
        
        if let user = user {
            self.id = user.id
            context.delete(user)
            DispatchQueue.main.async { try? context.save() }
        } else {
            // IN ERROR
        }
        
        return nil
    }

}
