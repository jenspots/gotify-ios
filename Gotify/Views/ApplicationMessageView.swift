//
//  ApplicationDetailView.swift
//  Gotify
//
//  Created by Jens Pots on 30/06/2022.
//

import CoreData
import PhotosUI
import SwiftUI

struct ApplicationMessageView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.editMode) var editMode

    @State private var application: Application
    @State private var selection = Set<Message>()
    @State private var searchTerm = ""

    @FetchRequest
    var messages: FetchedResults<Message>

    init(application: Application) {
        self._application = State(wrappedValue: application)

        _messages = FetchRequest<Message>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Message.date, ascending: false)],
            predicate: NSPredicate(format: "appid == %d", application.id),
            animation: .default
        )
    }

    func editing() -> Bool {
        if let editMode = editMode {
            return editMode.wrappedValue == .active
        } else {
            return false
        }
    }

    var body: some View {
        List(selection: $selection) {
            Section(content: {}, header: {
                HStack(alignment: .center) {
                    Spacer() // Required for some reason
                    VStack(alignment: .center) {
                        Image("mascott")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100)
                            .mask(Circle())
                            .padding(.top, -10)

                        Text(application.name ?? "")
                            .font(.title3)
                            .fontWeight(.medium)
                            .textCase(.none)
                        Text(application.about ?? "")
                            .font(.subheadline)
                            .fontWeight(.regular)
                            .textCase(.none)
                    }

                    Spacer() // Required for some reason
                }
            })
            .foregroundColor(colorScheme == .dark ? .white : .black)

            Section(header: Text("Notifications")) {
                ForEach(messages.filter { !$0.isDeleted }, id: \.self) { message in
                    NavigationLink(destination: MessageDetailView(application: application, message: message)) {
                        MessageRowComponent(message: message)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button { message.toggleRead() } label: {
                            if !message.read {
                                Label("Read", systemImage: "envelope.open")
                            } else {
                                Label("Unread", systemImage: "envelope.badge")
                            }
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task { await message.delete(context: context) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .refreshable { await Message.getAll(context: context, application: application) }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(application.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }

            ToolbarItem(placement: .navigationBarLeading) {
                if editing() && messages.count != selection.count {
                    Button(action: { messages.forEach { x in selection.insert(x) } }) {
                        Text("Select All")
                    }
                } else if editing() {
                    Button(action: { selection.removeAll() }) {
                        Text("Select None")
                    }
                }
            }

            ToolbarItemGroup(placement: .bottomBar) {
                if editing() {
                    HStack {
                        Button(action: {
                            selection.forEach { message in
                                message.markAsRead()
                            }
                        }) {
                            Text("Mark as read")
                        }
                        Spacer()
                        Button(action: {
                            selection.forEach { message in
                                selection.remove(message)
                                Task {
                                    await message.delete(context: context)
                                }
                            }
                        }) {
                            Text("Remove")
                        }
                    }
                    .padding(.bottom, 5)
                    .padding(.horizontal, -10)
                }
            }
        }
        .navigationBarBackButtonHidden(editing())
        .searchable(text: $searchTerm)
    }
}

struct ApplicationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
