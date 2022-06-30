//
//  Error.swift
//  Gotify
//
//  Created by Jens Pots on 28/06/2022.
//

import Foundation

struct GotifyError : Error, Decodable, Equatable {
    var error: String
    var errorCode : Int64
    var errorDescription: String
    
    static func unknown() -> GotifyError {
        return .init(
            error: "There was an issue during transmission.",
            errorCode: 1,
            errorDescription: "There was an issue during transmission."
        )
    }
}
