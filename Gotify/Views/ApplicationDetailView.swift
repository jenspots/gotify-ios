//
//  ApplicationDetailView.swift
//  Gotify
//
//  Created by Jens Pots on 30/06/2022.
//

import CoreData
import PhotosUI
import SwiftUI

struct ApplicationDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.editMode) var editing
    @Environment(\.dismiss) var dismiss
    
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
    
    func refresh() async {
        await Message.getAll(context: viewContext, application: application)
    }
    
    func delete(offsets: IndexSet) {
        for deletable in offsets.map{ messages[$0] } {
            Task { await deletable.delete(context: viewContext) }
        }
    }

    func deleteApp() {
        Task { await application.delete(context: viewContext) }
        viewContext.delete(application)
        try? viewContext.save()
        dismiss()
    }
    
    
    // photo
    @State var isSet: Bool = true
    @State var selection: UIImage = UIImage(named: "mascott")!
    @State private var showPopover = false
    // photo/
    
    var body: some View {
        List {
            Section(content: {}, header: {
                HStack(alignment: .center) {
                    Spacer() // Required for some reason
                    VStack(alignment: .center) {
                        ZStack {
                            Image(uiImage: selection)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100)

                            VStack {
                                Spacer()
                                if editing?.wrappedValue == .active {
                                    Text("Edit")
                                        .textCase(.none)
                                        .frame(width: 100, height: 30)
                                        .background(.thinMaterial)
                                        .colorInvert()
                                }

                            }
                        }
                        .mask(Circle())
                        .onTapGesture {
                            if editing?.wrappedValue == .active {
                                showPopover = true
                            }
                        }


                        if editing?.wrappedValue == .active {
                            TextField("Name", text: $title)
                                .textCase(.none)
                                .font(.title3.weight(.medium))
                                .multilineTextAlignment(.center)
                            TextField("About", text: $about)
                                .textCase(.none)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding(.top, -10.0)
                        } else {
                            Text(application.name ?? "")
                                .font(.title3)
                                .fontWeight(.medium)
                                .textCase(.none)
                            Text(application.about ?? "")
                                .font(.subheadline)
                                .fontWeight(.regular)
                                .textCase(.none)
                        }
                    }

                    Spacer() // Required for some reason
                }
            })
            .foregroundColor(.black)

            if editing?.wrappedValue == .active {
                Section(header: Text("Configuration")) {
                    Toggle("Notifications", isOn: $application.notifyUser)
                    HStack {
                        Text("Token")
                        Spacer()
                        Text(application.token ?? "")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Identifier")
                        Spacer()
                        Text(String(application.id))
                            .foregroundColor(.gray)
                    }
                    Text("Delete Application")
                    .onTapGesture(perform: deleteApp)
                    .foregroundColor(.red)
                }
            }

            Section(header: Text("Notifications")) {
                ForEach(messages) { message in
                    NavigationLink(destination: MessageDetailView(application: application, message: message)) {
                        MessageRowComponent(message: message)
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(application.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable { await refresh() }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if editing?.wrappedValue == .active {
                    Button("Done") {
                        editing?.wrappedValue = .inactive
                    }
                } else {
                    Button("Edit") {
                        editing?.wrappedValue = .active
                    }
                }
            }
        }
        .onChange(of: editing!.wrappedValue, perform: { value in
            if value.isEditing {
                
                // pass
            } else {
                application.name = title
                application.about = about
                Task { await application.put(context: viewContext) }
            }
        })
        .popover(isPresented: $showPopover) {
           ImagePicker(selectedImage: $selection, didSet: $isSet)
        }
    }
}

struct ApplicationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
