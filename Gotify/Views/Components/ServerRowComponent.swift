//
//  ServerRowComponent.swift
//  Gotify
//
//  Created by Jens Pots on 01/07/2022.
//

import SwiftUI

struct ServerRowComponent: View {

    @AppStorage("serverUrl") var serverUrl: String = ""
    @State var server: Server
    @State var connected: Bool? = nil
    
    let timer = Timer.publish(
        every: 5,
        on: .main,
        in: .common
    ).autoconnect()
    
    func checkHealth() {
        Task {
            let healthCheck = await Server.shared.healthCheck()
            connected = healthCheck.health && healthCheck.database
        }
    }
    
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
                    Text(serverUrl)
                        .fontWeight(.medium)
                        .lineLimit(1)
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
        .onReceive(timer) { _ in checkHealth() }
        .onAppear { checkHealth() }
        .padding(.vertical, 5)
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
