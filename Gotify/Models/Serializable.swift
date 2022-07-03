//
//  Serializable.swift
//  Gotify
//
//  Created by Jens Pots on 03/07/2022.
//

import SwiftyJSON

protocol Serializeable {    
    // Convert an instance to JSON
    func toJSON() -> JSON
    
    // Convert an object from JSON to an instance
    static func fromJSON(json: JSON) -> Self
}


extension Array: Serializeable where Iterator.Element: Serializeable {
    func toJSON() -> JSON {
        return JSON(self.map { $0.toJSON() })
    }
    
    static func fromJSON(json: JSON) -> Self {
        return json.arrayValue.map { Iterator.Element.fromJSON(json: $0) }
    }
}
