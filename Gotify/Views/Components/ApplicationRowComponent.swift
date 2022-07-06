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
        HStack(spacing: 15) {
            ZStack {
                Image("mascott")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                        .mask(Circle())
                Text("\(messages.count)")
                        .font(.footnote)
                        .padding(3)
                        .foregroundColor(.white)
                        .background(.red)
                        .cornerRadius(500)
                        .padding(.leading, 35)
                        .padding(.top, -25)
            }
            VStack(alignment: .leading) {
                Text(application.name ?? "")
                        .font(.title3)
                        .fontWeight(.medium)
                Text(application.about ?? "")
                        .font(.subheadline)
                        .fontWeight(.regular)
            }
        }
        .padding(.vertical, 5)
        .task { await Message.getAll(context: context, application: application)}
    }
}

struct ApplicationRowComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
