//
//  ServerModel.swift
//  Gotify
//
//  Created by Jens Pots on 30/06/2022.
//

import Foundation
import Alamofire

struct Server {
    var serverUrl: String
    var token: String
    var headers: HTTPHeaders
    
    init(serverUrl: String, token: String) {
        self.serverUrl = serverUrl
        self.token = token
        self.headers = [.init(name: "X-Gotify-Key", value: token)]
    }

    static var shared = Server(serverUrl: "https://notifications.jenspots.com", token: "CsgdEX0D2p2HRbJ")
}
