//
//  MessageRowComponent.swift
//  Gotify
//
//  Created by Jens Pots on 30/06/2022.
//

import SwiftUI

struct MessageRowComponent: View {
    @ObservedObject var message: Message

    var body: some View {
        HStack {
            VStack {
                Circle().frame(width: 10, height: 10)
                    .foregroundColor(.blue)
                    .opacity(message.read ? 0.0 : 1.0)
                    .padding(.top, 5)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 5) {
                    if let title = message.title {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                    } else {
                        Text("Notification")
                    }

                Text(message.message ?? "Removed")
                    .lineLimit(2)
                    .opacity(0.75)

                Text(message.date?.formatted(date: .numeric, time: .shortened) ?? "Removed")
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 5.0)
        .padding(.leading, -15.0)
    }
}

struct MessageRowComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
