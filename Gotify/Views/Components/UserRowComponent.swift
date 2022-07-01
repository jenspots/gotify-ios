//
//  UserRowComponent.swift
//  Gotify
//
//  Created by Jens Pots on 01/07/2022.
//

import SwiftUI

struct UserRowComponent: View {
    @State var userName: String
    @State var admin: Bool
    
    var body: some View {
        NavigationLink(destination: {}) {
            HStack {
                Text(userName)
                if admin {
                    Spacer()
                    Text("Admin")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
