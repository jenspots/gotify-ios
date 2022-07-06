//
// Created by Jens Pots on 06/07/2022.
//

import Foundation
import SwiftUI

struct WelcomeView: View {

    @State var url: String = ""
    @State var token: String = ""

    func saveCredentials() {
        UserDefaults.standard.set(url, forKey: "serverUrl")
        UserDefaults.standard.set(token, forKey: "serverToken")
    }

    var welcomeText: String =
    """
    Welcome to Gotify! To get started, please authenticate using your credentials. You can change these at any time in the settings menu.                   
    """

    var text: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hello there!")
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.black)
                    .textCase(.none)

            Text(welcomeText)
                    .font(.subheadline.weight(.regular))
                    .foregroundColor(.black)
                    .textCase(.none)
        }
        .padding(.horizontal, -20)
        .padding(.top, 20)
        .opacity(0.95)
    }

    var body: some View {
        NavigationView {
            List {

                Section(header: text) {}

                Section(header: Text("Server URL")) {
                    TextField("Location", text: $url)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                }

                Section(header: Text("Server Token")) {
                    SecureField("Token", text: $token)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                }

                Section(footer: Button(action: saveCredentials) {
                    Text("Connect")
                }
                        .font(.headline.weight(.medium))
                        .tint(.blue)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .controlSize(.large)
                        .frame(width: 500)
                        .disabled(url == "" || token == "")
                ) { EmptyView() }
            }
            .navigationBarHidden(true)
        }
        .interactiveDismissDisabled()
    }
}
