//
//  ApplicationModel+CoreDataClass.swift
//  Gotify
//
//  Created by Jens Pots on 30/06/2022.
//
//

import Alamofire
import CoreData
import Foundation

public class ApplicationModel: NSManagedObject {
    /* Intermediary that allows us to decode the JSON response for now. */
    private struct Application: Decodable {
        var id: Int64
        var description: String
        var image: String
        var name: String
        var token: String
    }
    
    /* Generate an ApplicationModel from an Application instance. */
    private static func fromApplication(context: NSManagedObjectContext, application: Application) {
        let newApp = ApplicationModel(context: context)
        newApp.id = application.id
        newApp.about = application.description
        newApp.image = application.image
        newApp.name = application.name
        newApp.token = application.token
    }

    func delete() async -> GotifyError? {
        print("Deleting application \(self.id)")
        let url = "\(Server.shared.serverUrl)/application/\(id)"

        print("REQUEST: DELETE \(url)")
        if let statusCode = await AF.request(
            url, method: .delete,
            headers: Server.shared.headers
        ).serializingData().response.response?.statusCode {
            print("Deleting application: response \(statusCode)")
            return nil
        } else {
            print("Deleting application: server error")
            return GotifyError.unknown()
        }
    }
    
    func put(context: NSManagedObjectContext) async -> GotifyError? {
        let url = NSURL(string: "\(Server.shared.serverUrl)/application/\(id)")
        print("REQUEST: PUT \(url!)")
        let request = NSMutableURLRequest(url: url! as URL)
        request.addValue(Server.shared.token, forHTTPHeaderField: "X-Gotify-Key")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        let session = URLSession(configuration:URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        let payload = "{\"description\": \"\(about!)\", \"name\": \"\(name!)\"}"
        request.httpBody = payload.data(using: String.Encoding.utf8)
        print(payload)
        if let (data, res) = try? await session.data(for: request as URLRequest) {
            if let statusCode = (res as? HTTPURLResponse?)??.statusCode {
                print("REQUEST: PUT CODE \(statusCode)")
                return nil
            }
        }
        
        return GotifyError.unknown()
    }

    
    /* Retrieve new Applications from the server. */
    static func refresh(context: NSManagedObjectContext) async -> GotifyError? {
        print("Retrieving Applications")
        let url = Server.shared.serverUrl + "/application"
        let request = AF.request(url, headers: Server.shared.headers)
        let successTask = request.serializingDecodable(Array<Application>.self)
        let errorTask = request.serializingDecodable(GotifyError.self)

        if let applications = try? await successTask.value {
            print("Retrieving Applications: Done")
            
            for application in applications {
                ApplicationModel.fromApplication(context: context, application: application)
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

        if let gotifyError = try? await errorTask.value {
            print("Retrieving Applications: A server error occured")
            return gotifyError

        }

        print("Retrieving Applications: A client error occured")
        return GotifyError.unknown()
    }
}
