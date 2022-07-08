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
    @State var editing = false

    init(application: Application) {
        self.application = application
    }

    var body: some View {
        NavigationButton {
            Task {
                await Message.getAll(context: context, application: application)
            }
        } destination: {
            ApplicationMessageView(application: application)
        } label: {
            HStack(alignment: .center, spacing: 15) {
                Image("mascott")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40)
                        .mask(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(application.name ?? "")
                            .font(.title3)
                            .fontWeight(.medium)
                    if let about = application.about {
                        if !about.isEmpty {
                            Text(about)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(.vertical, 10)
            .contextMenu {
                Button {
                    editing = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                Button {
                    Task {
                        let request = Message.fetchRequest()
                        let result = try? context.fetch(request) as [Message]
                        result?.forEach { $0.markAsRead() }
                        try? context.save()
                    }
                } label: {
                    Label("Mark All As Read", systemImage: "checkmark.circle")
                }
                Button(role: .destructive) {
                    Task { await application.delete(context: context) }
                } label: {
                    Label("Remove", systemImage: "trash")
                }
            }
            .background {
                NavigationLink(
                    isActive: $editing,
                    destination: { ApplicationDetailView(application: application) },
                    label: { EmptyView() }
                ).opacity(0.0)
            }
        }
    }
}

struct ApplicationRowComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
