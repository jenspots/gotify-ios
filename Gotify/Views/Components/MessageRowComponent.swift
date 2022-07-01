//
//  MessageRowComponent.swift
//  Gotify
//
//  Created by Jens Pots on 30/06/2022.
//

import SwiftUI

struct MessageRowComponent: View {
    var message: MessageModel

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let title = message.title {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
            }

            Text(message.message!.trimmingCharacters(in: .whitespacesAndNewlines))
                .lineLimit(3)

            Text(message.date!.formatted(date: .numeric, time: .shortened))
                .font(.subheadline)
                .lineLimit(1)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 5.0)
    }
}

struct MessageRowComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
