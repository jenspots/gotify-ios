//
//  PagingModel.swift
//  Gotify
//
//  Created by Jens Pots on 01/07/2022.
//

import Foundation

struct Paging: Codable {
    var limit: Int64
    var next: String?
    var since: Int64
    var size: Int64
}
