//
//  Error.swift
//  Gotify
//
//  Created by Jens Pots on 28/06/2022.
//

import Foundation
import SwiftyJSON

struct GotifyError: Error, Decodable, Equatable, Serializable {
    var error: String
    var errorCode: Int64
    var errorDescription: String

    // Serializable
    func toJSON() -> JSON {
        fatalError("Not implemented")
    }

    // Serializable
    static func fromJSON(json: JSON) -> Self {
        GotifyError(
            error: json["error"].string!,
            errorCode: json["errorCode"].int64!,
            errorDescription: json["errorDescription"].string!
        )
    }

    static func unknown() -> GotifyError {
        .init(
            error: "There was an issue during transmission.",
            errorCode: 1,
            errorDescription: "There was an issue during transmission."
        )
    }
}
