//
//  ApplicationListView.swift
//  Gotify
//
//  Created by Jens Pots on 30/06/2022.
//

import SwiftUI

struct ApplicationListView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest var apps: FetchedResults<Application>
    @State var newApplication: Bool = false

    init() {
        self._apps = Application.fetchAll()
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(apps) { application in
                    ApplicationRowComponent(application: application)
                }
                .onDelete { indices in
                    indices.forEach { index in
                        Task { await apps[index].delete(context: viewContext) }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { newApplication = true }) {
                        Label("New", systemImage: "plus")
                    }
                }
            }
            .navigationBarTitle("Applications")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .refreshable { await Application.getAll(context: viewContext) }
        .sheet(isPresented: $newApplication) {
            ApplicationNewView(isPresented: $newApplication)
        }
        .task { await Application.getAll(context: viewContext) }

    }
}

struct ApplicationListView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
