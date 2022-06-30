//
//  MessageDetailView.swift
//  Gotify
//
//  Created by Jens Pots on 30/06/2022.
//

import SwiftUI

struct MessageDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    var application: ApplicationModel
    var message: MessageModel

    func delete() {
        viewContext.delete(message)
        try? viewContext.save()
        dismiss()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(message.title ?? "Notification")
                .font(.title)
                .fontWeight(.bold)
            Text(message.date?.formatted(date: .numeric, time: .shortened) ?? "")
                .font(.subheadline)
                .fontWeight(.regular)
                .foregroundColor(Color.gray)
            Divider()
                .padding(.vertical, 10)
            Text(message.message ?? "")
            Spacer()
        }
        .frame(
          minWidth: 0,
          maxWidth: .infinity,
          minHeight: 0,
          maxHeight: .infinity,
          alignment: .topLeading
        )
        .padding()
        .background(.ultraThickMaterial)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: delete) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

struct MessageDetailView_Previews: PreviewProvider {
    static var message: MessageModel = {
        var result = MessageModel(context: PersistenceController.preview.container.viewContext)
        result.message = "Hello, world!"
        result.priority = 0
        result.date = .now
        result.title = "A Dummy Message"
        return result
    }()

    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
