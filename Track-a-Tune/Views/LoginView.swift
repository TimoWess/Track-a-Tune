//
//  LoginView.swift
//  Track-a-Tune
//
//  Created by Timo Wesselmann on 14.12.22.
//

import SwiftUI

struct LoginView: View {
    @StateObject var tuneTracker: TuneTracker
    @Binding var showAuthCodeTextField: Bool
    @Binding var authCode: String
    var body: some View {
        Button("Log in") {
            tuneTracker.requestUserAuthentication()
            showAuthCodeTextField = true
        }
        if showAuthCodeTextField {
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
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(tuneTracker: .shared, showAuthCodeTextField: .constant(true), authCode: .constant(""))
    }
}
