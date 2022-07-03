//
//  UserRowComponent.swift
//  Gotify
//
//  Created by Jens Pots on 01/07/2022.
//

import SwiftUI

struct UserRowComponent: View {
    var user: User
    
    var body: some View {
        NavigationLink(destination: {}) {
            KeyValueText(left: user.name!, right: user.admin ? "Admin" : "")
        }
    }
}
