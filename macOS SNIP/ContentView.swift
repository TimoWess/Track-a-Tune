//
//  ContentView.swift
//  macOS SNIP
//
//  Created by Timo Wesselmann on 05.03.22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var snip = Snip()
    @State var showAuthCodeTextField = false
    @State var authCode = ""
    @State var showLogOutConfirmation = false
    var body: some View {
        VStack {
            #if DEBUG
            Button("Refresh Token") {
                snip.refreshAccessToken()
            }
            Button("Make Request") {
                snip.makeRequst()
            }
            .padding()
            #endif
            if snip.isLoggedIn {
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
                        snip.logOut()
                    }
                }
                if snip.displayName != "" {
                    Text("Logged in as \"\(snip.displayName)\"")
                }
            } else {
                Button("Log in") {
                    snip.requestUserAuthentication()
                    showAuthCodeTextField = true
                }
            }
            if showAuthCodeTextField && !snip.isLoggedIn {
                Group {
                    TextField("Auth Code", text: $authCode)
                    Button("Request Access Token") {
                        snip.requestAccessToken(code: authCode)
                        if snip.isLoggedIn {
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
