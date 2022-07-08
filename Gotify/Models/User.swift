//
//  User+CoreDataClass.swift
//  Gotify
//
//  Created by Jens Pots on 03/07/2022.
//
//

import CoreData
import Foundation
import SwiftUI
import SwiftyJSON

public class User: NSManagedObject, Serializable {
    var password: String = ""

    var nameValue: String {
        get {
            name!
        }
        set { name = newValue }
    }

    static func new() -> User {
        User(entity: entity(), insertInto: nil)
    }

    // Serializable
    func toJSON() -> JSON {
        var result = JSON([
            "admin": admin,
            "name": name!
        ])

        if password != "" {
            result["pass"] = JSON(stringLiteral: password)
        }

        return result
    }

    // Serializable
    static func fromJSON(json: JSON) -> Self {
        let result = User.new()
        result.id = json["id"].int64!
        result.admin = json["admin"].bool ?? false
        result.name = json["name"].string!
        return result as! Self
    }

    /* Retrieve new users from the server. */
    static func getAll(context: NSManagedObjectContext) async -> GotifyError? {
        let (_, users): (Int, [User]?) = await API.request(
            slug: "/user",
            body: nil,
            method: .get
        )

        if let users = users {
            for user in users {
                do {
                    let request = User.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %d", user.id)
                    let queryResult = try context.fetch(request)

                    if queryResult.count > 2 {
                        fatalError("Core Data Error: uniqueness constrained broken")
                    }

                    if let queryResult = queryResult.first {
                        queryResult.admin = user.admin
                        queryResult.name = user.name
                    } else {
                        context.insert(user)
                    }

                    DispatchQueue.main.async { try? context.save() }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }

        return nil
    }

    // Push edited user to the server
    func put(context: NSManagedObjectContext) async -> GotifyError? {
        guard self.hasPersistentChangedValues || password != "" else {
            return nil
        }

        let (statusCode, _): (Int, User?) = await API.request(
            slug: "/user/\(id)",
            body: self,
            method: .post
        )

        if statusCode == 200 {
            password = "" // reset for security reasons
            DispatchQueue.main.async {
                try? context.save()
            }
        }
        return nil
    }

    // Delete client
    func delete(context: NSManagedObjectContext) async -> GotifyError? {
        let (_, _): (Int, Nil?) = await API.request(
            slug: "/user/\(id)",
            body: nil,
            method: .delete
        )

        context.delete(self)
        DispatchQueue.main.async { try? context.save() }

        return nil
    }

    static func fetchAll() -> FetchRequest<User> {
        FetchRequest<User>(
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
            context.insert(user)
            DispatchQueue.main.async { try? context.save() }
        } else {
            // IN ERROR
        }

        return nil
    }
}
