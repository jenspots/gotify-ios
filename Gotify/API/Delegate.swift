//
//  Delegate.swift
//  Gotify
//
//  Created by Jens Pots on 28/06/2022.
//

import Alamofire
import Combine
import Foundation

class Delegate: ObservableObject {
    var serverUrl: String
    var token: String
    var headers: HTTPHeaders
    var decoder: JSONDecoder = JSONDecoder()
    
    @Published var applications: [Application] = []

    init(serverUrl: String, token: String) {
        print("Initializing Server Delegate")
        self.serverUrl = serverUrl
        self.token = token
        self.headers = [.init(name: "X-Gotify-Key", value: token)]
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
        
    func getApplications() async -> Result<(), GotifyError> {
        print("Retrieving Applications")
        let url = serverUrl + "/application"
        let request = AF.request(url, headers: headers)
        let successTask = request.serializingDecodable(Array<Application>.self)
        let errorTask = request.serializingDecodable(GotifyError.self)

        if let applications = try? await successTask.value {
            print("Retrieving Applications: Done")
            self.applications = applications
            return Result.success(())
        }
        
        
        if let gotifyError = try? await errorTask.value {
            print("Retrieving Applications: A server error occured")
            return Result.failure(gotifyError)
            
        }
        
        print("Retrieving Applications: A client error occured")
        return Result.failure(GotifyError.unknown())
    }
    
    func getMessages(application: Application, limit: Int = 100, since: Int? = nil) async -> Result<(), GotifyError> {
        print("Retrieving messages for \(application.name)")

        // Build the appriopriate URL
        // TODO: if application.messagePaging exists, we must continue there! Also check for newer onces
        var url: String = serverUrl + "/application/\(application.id)/message"
        url += "?limit=\(limit)" + (since != nil ? "&since=\(since!)" : "")
                
        // Retrieve raw data from the server
        guard let data = try? await AF.request(url, headers: headers).serializingData().value
        else {
            return Result.failure(GotifyError.unknown())
        }
        
        // The structure of the data returned from the server
        struct PaginatedMessages: Codable {
            var messages: [Message]
            var paging: Paging
        }
        
        // In case of a server error
        if let result = try? decoder.decode(GotifyError.self, from: data) {
            return Result.failure(result)
        }
        
        // In case of success
        if let result = try? decoder.decode(PaginatedMessages.self, from: data) {
            print("Retrieved messages succesfully")
            application.setMessages(messages: result.messages)
            return Result.success(())
        }

        // Return an error
        return Result.failure(GotifyError.unknown())
    }
    
    func deleteMessage(application: Application, messageIndex: Int) async {
        print("Deleting message \(messageIndex)")
        if let message = application.messages?[messageIndex] {
            let url = "\(serverUrl)/message/\(message.id)"
            print("REQUEST: DELETE \(url)")
            if let statusCode = await AF.request(url, method: .delete, headers: headers).serializingData().response.response?.statusCode {
                print("Deleting message: response \(statusCode)")
                application.removeMessage(index: messageIndex)
            } else {
                print("Deleting message: server error")
            }
        } else {
            print("Deleting message: did not exist!")
        }
    }
}
