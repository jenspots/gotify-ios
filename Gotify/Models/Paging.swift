//
//  PagingModel.swift
//  Gotify
//
//  Created by Jens Pots on 01/07/2022.
//

import SwiftyJSON
import Foundation

struct Paging: Serializeable {
    var limit: Int64
    var next: String?
    var since: Int64
    var size: Int64
    
    func toJSON() -> JSON {
        var result = JSON([
            "limit": limit,
            "since": since,
            "size": size
        ])
        
        if let next = next {
            result["next"] = JSON(next)
        }
        
        return result
    }
    
    static func fromJSON(json: JSON) -> Paging {
        return Paging(
            limit: json["limit"].int64!,
            next: json["next"].string,
            since: json["since"].int64!,
            size: json["size"].int64!
        )
    }
}
