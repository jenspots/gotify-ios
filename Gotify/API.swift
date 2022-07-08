//
//  API.swift
//  Gotify
//
//  Created by Jens Pots on 03/07/2022.
//

import Foundation
import SwiftyJSON
import SwiftUI

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

    public static func request<T: Serializable>(slug: String, body: T?, method: Method, verbose: Bool = true) async -> (Int, T?) {

        guard Server.shared.valid() else {
            return (0, nil)
        }

        // Craft the request
        var request = URLRequest(url: URL(string: Server.shared.serverUrl + slug)!)
        request.addValue(Server.shared.token, forHTTPHeaderField: "X-Gotify-Key")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = method.rawValue

        if verbose {
            print("REQUEST: \(Server.shared.serverUrl + slug)")
        }

        // Add data if it is supplied
        if let body = body {
            if let bodyAsString = try? body.toJSON().rawData() {
                if verbose {
                    print("DATA TO SEND: \(body.toJSON().rawString()!)")
                }
                request.httpBody = bodyAsString
            } else {
                if verbose {
                    print("ERROR: could not encode the supplied data in the request")
                }
                return (0, nil)
            }
        } else if verbose {
            print("DATA TO SEND: None")
        }

        // Make the request asynchronously
        guard let (rawData, rawResponse) = try? await URLSession.shared.data(for: request)
        else {
            if verbose {
                print("ERROR: could not make request.")
            }
            return (0, nil)
        }

        // Parse the response headers
        guard let response = rawResponse as? HTTPURLResponse
        else {
            if verbose {
                print("ERROR: could not parse response headers.")
            }
            return (0, nil)
        }

        // Print the resulting JSON data
        guard let jsonString = try? JSON(data: rawData).rawString()
        else {
            if verbose {
                print("ERROR: could not parse response data.")
            }
            return (0, nil)
        }

        if verbose {
            print("DATA RECEIVED: \(jsonString)")
        }

        // Parse the response data
        guard let data = try? T.fromJSON(json: JSON(data: rawData))
        else {
            if verbose {
                print("ERROR: could not parse response data.")
            }
            return (0, nil)
        }

        // Return the parsed result
        if verbose {
            print("RESPONSE: \(response.statusCode)")
        }
        return (response.statusCode, data)
    }

}
