//
//  ServerModel.swift
//  Gotify
//
//  Created by Jens Pots on 30/06/2022.
//

import Foundation
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
    var serverUrl: String
    var token: String

    init(serverUrl: String, token: String) {
        self.serverUrl = serverUrl
        self.token = token
    }

    static var shared = Server(serverUrl: "https://notifications.jenspots.com", token: "CsgdEX0D2p2HRbJ")

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
            method: .get
        )

        if let healthCheck = healthCheck {
            return healthCheck
        } else {
            return HealthCheck(database: false, health: false)
        }
    }
}
