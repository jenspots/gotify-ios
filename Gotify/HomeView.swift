//
//  HomeView.swift
//  Gotify
//
//  Created by Jens Pots on 28/06/2022.
//

import SwiftUI

struct ApplicationDetailView: View {
    @ObservedObject var application: Application
    var delegate: Delegate

    @State var active: Bool = true
    @State var showSettings: Bool = false
    
    func refresh() {
        Task { await delegate.getMessages(application: application) }
    }
    
    func delete(indices: IndexSet) {
        for index in indices {
            Task { await delegate.deleteMessage(application: application, messageIndex: index)}
        }
    }

    var body: some View {
        List {
            Section(content: {}, header: {
                HStack(alignment: .center) {
                    Spacer() // Required for some reason
                    VStack(alignment: .center) {
                        ZStack {
                            Image("mascott")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 70)
                                .blur(radius: showSettings ? 10 : 0.0)
                                .mask(Circle())
                                .brightness(showSettings ? -0.5 : 0.0)
                            
                            if showSettings {
                                Text("Edit")
                                    .font(.footnote)
                                    .colorInvert()
                            }
                        }
                        
                        Text(application.name)
                            .font(.title3)
                            .fontWeight(.medium)
                            .textCase(.none)
                        Text(application.description)
                            .font(.subheadline)
                            .fontWeight(.regular)
                            .textCase(.none)
                    }
                    .foregroundColor(.primary)
                    Spacer() // Required for some reason
                }
            })
            
            if showSettings {
                Section(header: Text("Configuration")) {
                    Toggle("Notifications", isOn: $active)
                    HStack {
                        Text("Token")
                        Spacer()
                        Text(application.token)
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Identifier")
                        Spacer()
                        Text(String(application.id))
                            .foregroundColor(.gray)
                    }
                    Button("Delete") {}
                    .foregroundColor(.red)
                }
            }
                

            Section(header: Text("Notifications")) {
                ForEach(application.messages ?? []) { message in
                    NavigationLink(destination: MessageView(message: message, delegate: delegate)) {
                        MessageComponent(message: message)
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(application.name)
        .navigationBarTitleDisplayMode(.inline)
        .task { refresh() }
        .refreshable { refresh() }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    if !showSettings {
                        Label("Settings", systemImage: "safari")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showSettings.toggle() }) {
                    if !showSettings {
                        Label("Settings", systemImage: "gear")
                    } else {
                        Text("Done")
                    }
                }
            }
        }
    }
}


struct MessageView: View {
    var message: Message
    var delegate: Delegate

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(message.title ?? "Notification")
                .font(.title)
                .fontWeight(.bold)
            Text(message.date.formatted(date: .numeric, time: .shortened))
                .font(.subheadline)
                .fontWeight(.regular)
                .foregroundColor(Color.gray)
            Text(message.message)
            Spacer()
        }
        .padding()
        .background(.ultraThickMaterial)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }

    }
}

struct MessageComponent: View {
    var message: Message

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title = message.title {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(2)
            }
            
            Text(message.message.trimmingCharacters(in: .whitespacesAndNewlines))
                .lineLimit(3)
            
            Text(message.date.formatted(date: .numeric, time: .shortened))
                .font(.subheadline)
                .lineLimit(1)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 5.0)
    }
}

struct ApplicationView: View {
    @State var application: Application
    @StateObject var delegate: Delegate

    var body: some View {
        HStack(spacing: 15) {
            Image("mascott")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40)
                .mask(Circle())
            VStack(alignment: .leading) {
                Text(application.name)
                    .font(.title3)
                    .fontWeight(.medium)
                Text(application.description)
                    .font(.subheadline)
                    .fontWeight(.regular)
            }
        }
        .padding(.vertical, 5)
    }
}

struct HomeView: View {
    @ObservedObject var delegate: Delegate

    init() {
        delegate = .init(
            serverUrl: "https://notifications.jenspots.com",
            token: "CsgdEX0D2p2HRbJ"
        )
    }
    
    func refreshData() async {
        await delegate.getApplications()
    }
    
    var body: some View {
        TabView {
            NavigationView {
                List {
                    ForEach(delegate.applications) { application in
                        NavigationLink(destination: ApplicationDetailView(application: application, delegate: delegate)) {
                            ApplicationView(application: application, delegate: delegate)
                        }
                    }
                }
                .navigationTitle("Applications")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {}) {
                            Label("New Application", systemImage: "plus")
                        }
                    }
                }
            }
            .task { await refreshData() }
            .refreshable { await refreshData() }
            .tabItem { Label("Applications", systemImage: "antenna.radiowaves.left.and.right")}

            VStack {
            }
            .tabItem { Label("Notifications", systemImage: "list.bullet")}

            VStack {
            }
            .tabItem { Label("Settings", systemImage: "gear")}
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
