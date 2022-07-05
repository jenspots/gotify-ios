//
//  ApplicationListView.swift
//  Gotify
//
//  Created by Jens Pots on 30/06/2022.
//

import SwiftUI

struct ApplicationListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Application.name, ascending: true)], animation: .default)
    var apps: FetchedResults<Application>
    
    private func delete(offsets: IndexSet) {
        let deletables = offsets.map{ apps[$0] }

        for deletable in deletables {
            Task { await deletable.delete(context: viewContext) }
        }

        try? viewContext.save()
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(apps) { application in
                    NavigationLink(destination: ApplicationMessageView(application: application)) {
                        ApplicationRowComponent(application: application)
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Applications")
        }
        .refreshable { await Application.getAll(context: viewContext) }
    }
}

struct ApplicationListView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
