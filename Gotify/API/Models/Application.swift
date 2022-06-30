//
//  Application.swift
//  Gotify
//
//  Created by Jens Pots on 28/06/2022.
//

import Foundation

class Application : Identifiable, Codable, Comparable, ObservableObject {
    var id: Int64
    var description: String
    var image: String
    var name: String
    var token: String
    
    var messages: [Message]?
    var messagePage: Paging?
    
    func addMessage(message: Message) {
        messages?.append(message)
        objectWillChange.send()
    }
    
    func setMessages(messages: [Message]) {
        self.messages = messages
        objectWillChange.send()
    }
    
    func removeMessage(index: Int) {
        messages?.remove(at: index)
        objectWillChange.send()
    }
        
    static func < (lhs: Application, rhs: Application) -> Bool {
        lhs.name < rhs.name
    }
    
    static func == (lhs: Application, rhs: Application) -> Bool {
        lhs.id == rhs.id
    }
}
