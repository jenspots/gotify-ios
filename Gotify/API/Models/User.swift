//
//  User.swift
//  Gotify
//
//  Created by Jens Pots on 28/06/2022.
//

import Foundation

struct User: Identifiable {
    let id: Int64
    var admin: Bool?
    var name: String
}
