//
//  Track-a-Tune.swift
//  Track-a-Tune
//
//  Created by Timo Wesselmann on 05.03.22.
//

import SwiftUI

@main
struct Track_A_TuneApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .handlesExternalEvents(preferring: Set(arrayLiteral: ""), allowing: Set(arrayLiteral: "*")) // activate existing window if exists
                .onOpenURL { url in
                    print(url)
                    guard let url = URLComponents(string: url.absoluteString) else { return }
                    guard let code = url.queryItems?.first(where: { $0.name == "code" })?.value else {
                        print("No code in URL")
                        return
                    }
                    TuneTracker.shared.requestAccessToken(code: code)
                }
        }
    }
}
