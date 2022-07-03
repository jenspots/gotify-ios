//
//  API.swift
//  Gotify
//
//  Created by Jens Pots on 03/07/2022.
//

import Foundation
import SwiftyJSON

enum Method: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct API {
    
    private static let encoder = JSONEncoder()
    
    private static let decoder: JSONDecoder = {
        let decoder: JSONDecoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()
    
    private static let session = URLSession(configuration:URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
    
    public static func request<T: Serializeable>(slug: String, body: T?, method: Method) async -> (Int, T?) {
        // Craft the request
        let request = NSMutableURLRequest(url: URL(string: Server.shared.serverUrl + slug)!)
        request.addValue(Server.shared.token, forHTTPHeaderField: "X-Gotify-Key")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = method.rawValue
        
        print("REQUEST: \(Server.shared.serverUrl + slug)")
        
        // Add data if it is supplied
        if let body = body {
            if let bodyAsString = try? body.toJSON().rawData() {
                print("DATA TO SEND: \(body.toJSON().rawString()!)")
                request.httpBody = bodyAsString
            } else {
                print("ERROR: could not encode the supplied data in the request")
                return (0, nil)
            }
        } else {
            print("DATA TO SEND: None")
        }
        
        // Make the request asynchronously
        guard let (rawData, rawResponse) = try? await API.session.data(for: request as URLRequest)
        else {
            print("ERROR: could not make request.")
            return (0, nil)
        }
        
        // Parse the response headers
        guard let response = rawResponse as? HTTPURLResponse
        else {
            print("ERROR: could not parse response headers.")
            return (0, nil)
        }
        
        // Print the resulting JSON data
        guard let jsonString = try? JSON(data: rawData).rawString()
        else {
            print("ERROR: could not parse response data.")
            return (0, nil)
        }
        print("DATA RECEIVED: \(jsonString)")
        
        // Parse the response data
        guard let data = try? T.fromJSON(json: JSON(data: rawData))
        else {
            print("ERROR: could not parse response data.")
            return (0, nil)
        }
        
        // Return the parsed result
        print("RESPONSE: \(response.statusCode)")
        return (response.statusCode, data)
    }
    
}
