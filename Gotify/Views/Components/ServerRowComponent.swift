//
//  ServerRowComponent.swift
//  Gotify
//
//  Created by Jens Pots on 01/07/2022.
//

import SwiftUI

struct ServerRowComponent: View {
    @State var server: Server
    @State var connected: Bool? = nil
    
    var body: some View {
        NavigationLink(destination: ServerDetailView()) {
            HStack(alignment: .center, spacing: 15) {
                Image(systemName: "globe.europe.africa.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40)
                    .foregroundColor(connected != nil ? (connected! ? .green : .red) : .gray)
                    .saturation(0.75)
                VStack(alignment: .leading, spacing: 2) {
                    Text(Server.shared.urlSansProtocol())
                        .fontWeight(.medium)
                    if let connected = connected {
                        Text(connected ? "Connected" : "Unreachable")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    } else {
                        Text("Unknown")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.vertical, 5)
        }
        .onAppear {
            Task {
                let healthCheck = await Server.shared.healthCheck()
                connected = healthCheck.health && healthCheck.database
            }
        }
    }
}

struct ServerRowComponent_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                ServerRowComponent(server: .shared, connected: true)
            }
        }
    }
}
