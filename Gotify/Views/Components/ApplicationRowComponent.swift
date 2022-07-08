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
                            .fontWeight(.medium)
                    Text(application.about ?? "")
                            .font(.footnote)
                            .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 10)
        }
    }
}

struct ApplicationRowComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
