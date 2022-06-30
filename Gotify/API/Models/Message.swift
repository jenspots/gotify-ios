//
//  Message.swift
//  Gotify
//
//  Created by Jens Pots on 28/06/2022.
//

import Foundation

struct Message: Identifiable, Codable, Comparable, Hashable {
    var id: Int64
    var appid: Int
    var date: Date
    var message: String
    var priority: Int64?
    var title: String?

    static func < (lhs: Message, rhs: Message) -> Bool {
        lhs.date < rhs.date
    }
}
