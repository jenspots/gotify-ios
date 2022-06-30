//
//  Client.swift
//  Gotify
//
//  Created by Jens Pots on 28/06/2022.
//

import Foundation

struct Client: Identifiable {
    let id: Int64
    var name: String
    let token: String
}
