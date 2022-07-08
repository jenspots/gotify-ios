//
//  ServerModel.swift
//  Gotify
//
//  Created by Jens Pots on 30/06/2022.
//

import Foundation
import SwiftUI
import SwiftyJSON

struct HealthCheck: Serializable {
    let database: Bool
    let health: Bool

    // Serializable
    func toJSON() -> JSON {
        fatalError("Not implemented")
    }

    // Serializable
    static func fromJSON(json: JSON) -> Self {
        let database = json["database"].string!
        let health = json["health"].string!
        return HealthCheck(database: database == "green", health: health == "green")
    }
}

struct Server {
    @AppStorage("serverUrl") var serverUrl: String = ""
    @AppStorage("serverToken") var token: String = ""

    // No need to allow new instances just yet.
    private init() {}

    // Singleton instance using AppStorage.
    static var shared = Server()

    func urlSansProtocol() -> String {
        if serverUrl.prefix(8) == "https://" {
            return String(serverUrl.suffix(serverUrl.lengthOfBytes(using: .utf8) - 8))
        } else if serverUrl.prefix(7) == "http://" {
            return String(serverUrl.suffix(serverUrl.lengthOfBytes(using: .utf8) - 7))
        } else {
            return serverUrl // TODO: should probably be illegal
        }
    }

    func healthCheck() async -> HealthCheck {
        let (_, healthCheck): (Int, HealthCheck?) = await API.request(
            slug: "/health",
            body: nil,
            method: .get,
            verbose: false
        )

        if let healthCheck = healthCheck {
            return healthCheck
        } else {
            return HealthCheck(database: false, health: false)
        }
    }

    func valid() -> Bool {
        serverUrl != "" && token != ""
    }
}
