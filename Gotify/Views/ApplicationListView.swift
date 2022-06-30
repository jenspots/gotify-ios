//
//  ApplicationListView.swift
//  Gotify
//
//  Created by Jens Pots on 30/06/2022.
//

import SwiftUI

struct ApplicationListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ApplicationModel.name, ascending: true)], animation: .default)
    var apps: FetchedResults<ApplicationModel>

    func refreshData() async {
        await ApplicationModel.refresh(context: viewContext)
    }

    func newApplication() {
        let app = ApplicationModel(context: viewContext)
        app.id = 0
        app.token = "secret-token"
        app.image = "mascott"
        app.name = "My Application"
        app.about = "This is a dummy value"

        try? viewContext.save()
    }
    
    private func delete(offsets: IndexSet) {
        let deletables = offsets.map{ apps[$0] }

        for deletable in deletables {
            Task { await deletable.delete() }
            viewContext.delete(deletable)
        }

        try? viewContext.save()
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(apps) { application in
                    NavigationLink(destination: ApplicationDetailView(application: application)) {
                        ApplicationRowComponent(application: application)
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Applications")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: newApplication) {
                        Label("New Application", systemImage: "plus")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
        .task { await refreshData() }
        .refreshable { await refreshData() }
    }
}

struct ApplicationListView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
