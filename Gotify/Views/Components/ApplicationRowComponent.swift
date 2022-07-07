//
//  ApplicationRowComponent.swift
//  Gotify
//
//  Created by Jens Pots on 30/06/2022.
//

import SwiftUI

struct ApplicationRowComponent: View {

    @Environment(\.managedObjectContext) private var context
    @ObservedObject var application: Application
    @FetchRequest var messages: FetchedResults<Message>
    
    init(application: Application) {
        self.application = application
        self._messages = Message.fetchUnreadCount(application: application)
    }
    
    var body: some View {
        NavigationLink(destination: ApplicationMessageView(application: application)) {
            HStack(alignment: .center, spacing: 15) {
                Image("mascott")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40)
                        .mask(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(application.name ?? "") (\(messages.count))")
                            .fontWeight(.medium)
                    Text(application.about ?? "")
                            .font(.footnote)
                            .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 10)
        }
        .task { await Message.getAll(context: context, application: application)}
    }
}

struct ApplicationRowComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
