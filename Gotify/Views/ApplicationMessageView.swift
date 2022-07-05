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
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State var title: String
    @State var about: String

    @FetchRequest
    var messages: FetchedResults<Message>
    
    init(application: Application) {
        self.application = application
        
        _messages = FetchRequest<Message>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Message.date, ascending: false)],
            predicate: NSPredicate(format: "appid == %d", application.id),
            animation: .default
        )
        
        _title = State(initialValue: application.name!)
        _about = State(initialValue: application.about!)
    }


    @ObservedObject var application: Application

    @State var active: Bool = true
    @State var presentConfig: Bool = false
    
    func refresh() async {
        await Message.getAll(context: viewContext, application: application)
    }
    
    func delete(offsets: IndexSet) {
        for deletable in offsets.map({ messages[$0] }) {
            Task { await deletable.delete(context: viewContext) }
        }
    }

    func deleteApp() {
        Task { await application.delete(context: viewContext) }
        dismiss()
    }
    
    @State var settingsPopover: Bool = false
        
    var body: some View {
        List {
            Section(content: {}, header: {
                HStack(alignment: .center) {
                    Spacer() // Required for some reason
                    VStack(alignment: .center) {
                        Image("mascott")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100)
                            .mask(Circle())

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
                ForEach(messages) { message in
                    NavigationLink(destination: MessageDetailView(application: application, message: message)) {
                        MessageRowComponent(message: message)
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .refreshable {
            await refresh()
        }
        .navigationBarItems(trailing: NavigationLink(destination: ApplicationDetailView(application: application)) {
            Text("Edit")
        })
//        .background {
//            NavigationLink(
//                destination: ApplicationDetailView(application: application),
//                isActive: $presentConfig
//            ) {
//                EmptyView()
//            }
//            .hidden()
//        }
//        .toolbar(content: {
//            ToolbarItem {
//                Button(action: { presentConfig.toggle() }) {
//                    Label("Edit", systemImage: "gear")
//                }
//            }
//        })
        .listStyle(GroupedListStyle())
        .navigationBarTitle(application.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ApplicationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
