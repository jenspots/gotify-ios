//
//  Serializable.swift
//  Gotify
//
//  Created by Jens Pots on 03/07/2022.
//

import SwiftyJSON

protocol Serializable {
    // Convert an instance to JSON
    func toJSON() -> JSON

    // Convert an object from JSON to an instance
    static func fromJSON(json: JSON) -> Self
}

struct Nil: Serializable {
    func toJSON() -> JSON {
        JSON()
    }

    static func fromJSON(json: JSON) -> Self {
        Nil()
    }
}

extension Array: Serializable where Iterator.Element: Serializable {
    func toJSON() -> JSON {
        JSON(self.map { $0.toJSON() })
    }

    static func fromJSON(json: JSON) -> Self {
        json.arrayValue.map { Iterator.Element.fromJSON(json: $0) }
    }
}
