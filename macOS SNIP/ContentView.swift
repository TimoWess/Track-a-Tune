//
//  ContentView.swift
//  macOS SNIP
//
//  Created by Timo Wesselmann on 05.03.22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var snip = Snip()
    var body: some View {
        VStack {
            Button("Get Auth Code") {
                snip.requestUserAuthentication()
            }
            Button("Get Access Token") {
                snip.requestAccessToken()
            }
            .padding()
            Button("Refresh Token") {
                snip.refreshAccessToken()
            }
            Button("Make Request") {
                snip.makeRequst()
            }
            .padding()
            Button(snip.isLoggedIn ? "Log out" : "Log in") {
                if snip.isLoggedIn {
                    snip.logOut()
                } else {
                    snip.requestUserAuthentication()
                }
            }
        }
        .frame(width: 300, height: 400, alignment: .center)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
