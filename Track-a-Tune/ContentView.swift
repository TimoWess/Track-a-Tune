//
//  ContentView.swift
//  Track-a-Tune
//
//  Created by Timo Wesselmann on 05.03.22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var tuneTracker = TuneTracker.shared
    
    @State var showAuthCodeTextField    = false
    @State var showLogOutConfirmation   = false
    @State var authCode                 = ""
    
    var body: some View {
        VStack {
#if DEBUG
            Button("Refresh Token") {
                tuneTracker.refreshAccessToken()
            }
            Button("Make Request") {
                tuneTracker.makeRequst()
            }
            .padding()
#endif
            if tuneTracker.isLoggedIn {
                Spacer()
                HStack {
                    TextField("Output Format", text: $tuneTracker.textFormat)
                    Toggle("Download Artwort", isOn: $tuneTracker.downloadArtwork)
                }
                Button("Set Save Location") {
                    tuneTracker.selectFolder()
                }
                Spacer()
                Button("Log out") {
                    showAuthCodeTextField = false
                    showLogOutConfirmation = true
                }
                .alert("Are you sure?", isPresented: $showLogOutConfirmation) {
                    Button("Cancle") {
                        print("Cancled loggout")
                    }
                    Button("Yes") {
                        print("Logged out")
                        tuneTracker.logOut()
                    }
                }
                if tuneTracker.displayName != "" {
                    Text("Logged in as \"\(tuneTracker.displayName)\"")
                }
            } else {
                Button("Log in") {
                    tuneTracker.requestUserAuthentication()
                    showAuthCodeTextField = true
                }
            }
            if showAuthCodeTextField && !tuneTracker.isLoggedIn {
                Group {
                    TextField("Auth Code", text: $authCode)
                    Button("Request Access Token") {
                        tuneTracker.requestAccessToken(code: authCode)
                        if tuneTracker.isLoggedIn {
                            showAuthCodeTextField.toggle()
                        }
                    }
                }
            }
            
        }
        .frame(width: 300, height: 200, alignment: .center)
        .padding(20)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
