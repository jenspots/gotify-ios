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

    var application: Application
    var message: Message
    
    @State var title: String
    @State var messageBody: String
    
    init(application: Application, message: Message) {
        self.application = application
        self.message = message

        _title = State(initialValue: message.title ?? "")
        _messageBody = State(initialValue: message.message!)
    }

    func delete() {
        Task { await message.delete(context: viewContext) }
        dismiss()
    }

    var body: some View {
        List {
            Text(title)
                .font(.title.bold())
                .listRowSeparator(.hidden)
            Text(message.date?.formatted(date: .numeric, time: .shortened) ?? "")
                .font(.subheadline)
                .fontWeight(.regular)
                .foregroundColor(Color.gray)
            Text(message.message ?? "")
                .listRowSeparator(.hidden)
        }
        .listStyle(PlainListStyle())
        .frame(
          minWidth: 0,
          maxWidth: .infinity,
          minHeight: 0,
          maxHeight: .infinity,
          alignment: .topLeading
        )
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
    static var message: Message = {
        var result = Message(context: PersistenceController.preview.container.viewContext)
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
