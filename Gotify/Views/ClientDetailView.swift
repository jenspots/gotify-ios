//
//  ClientDetailView.swift
//  Gotify
//
//  Created by Jens Pots on 02/07/2022.
//

import SwiftUI

struct ClientDetailView: View {
    @Environment(\.dismiss) var dismiss

    @State var name: String
    @State var token: String
    
    @State var alert: Bool = false

    var body: some View {
        List {
            Section(header: Text("Details")) {
                NavigationLink(destination: {}) {
                    KeyValueText(left: "Name", right: "Safari")
                }
                SensitiveText(left: "Token", right: token)
                    .onTapGesture {
                        alert.toggle()
                    }
                Text("Delete Client")
                    .foregroundColor(.red)
                    .onTapGesture {
                        // TODO: DELETE REQUEST
                        dismiss()
                    }
            }
            .alert("Tokens cannot be changed.", isPresented: $alert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}



struct ClientDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ClientDetailView(name: "Safari", token: "very-secret-token")
        }
    }
}
