//
//  ApplicationRowComponent.swift
//  Gotify
//
//  Created by Jens Pots on 30/06/2022.
//

import SwiftUI

struct ApplicationRowComponent: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var application: Application

    var body: some View {
        HStack(spacing: 15) {
            Image("mascott")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40)
                .mask(Circle())
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
    }
}

struct ApplicationRowComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
