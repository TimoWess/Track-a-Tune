//
//  ContentView.swift
//  macOS SNIP
//
//  Created by Timo Wesselmann on 05.03.22.
//

import SwiftUI

struct ContentView: View {
    @State var accessToken = ""
    var body: some View {
        VStack {
            Button("Get Auth Code") {
                requestUserAuthentication()
            }
            Button("Get Access Token") {
                requestAccessToken()
            }
            .padding()
            Button("Refresh Token") {
                refreshAccessToken()
            }
            Button("Make Request") {
                makeRequst()
            }
        }
        .frame(width: 300, height: 400, alignment: .center)
    }
}

func requestUserAuthentication() {
    
    // Define Api endpoint and query parameters
    let endpoint = "https://accounts.spotify.com/authorize?"
    let clientId = UserSecrets.CLIENT_ID
    let redirectUri = "http://localhost:10597/"
    let responseType = "code"
    let scope = "user-read-currently-playing"
    let showDialog = "true"
    
    // Build URL
    var urlComponents = URLComponents(string: endpoint)!
    let urlQueryParams: [URLQueryItem] =
    [
        .init(name: "client_id", value: clientId),
        .init(name: "response_type", value: responseType),
        .init(name: "redirect_uri", value: redirectUri),
        .init(name: "scope", value: scope),
        .init(name: "show_dialog", value: showDialog)
    ]
    urlComponents.queryItems = urlQueryParams
    
    let url = urlComponents.url!
    print(url)
    NSWorkspace.shared.open(url)
    
}

func requestAccessToken() {
    
    let endpoint = "https://accounts.spotify.com/api/token"
    let grantType = "authorization_code"
    let code = "AQA4sf6vODvHmw7-xgRz-IcSmsfH0QqyM-YW7TuLV-x7BlxfZjExERyCrnAovo6NoSTm_1GgnD0htFBQXA1XcIwOgMT_vdYsjUyJk0XL9_cph9Az9NpDmcrP2bqf7XmERKvZUD-IfomOWJaueVgdzlIZiFZX0tEg-H3wY1nvuUkZdK50dshyEKI5X180x_oJ63WvmfeQiaE"
    let redirectUri = "http://localhost:10597/"
    
    var requestBodyCompomnents = URLComponents()
    requestBodyCompomnents.queryItems =
    [
        .init(name: "grant_type", value: grantType),
        .init(name: "code", value: code),
        .init(name: "redirect_uri", value: redirectUri)
    ]
    
    // Define headers
    let contentType = "application/x-www-form-urlencoded"
    let authorization = "Basic \((UserSecrets.CLIENT_ID + ":" + UserSecrets.CLIENT_SECRET).data(using: .utf8)!.base64EncodedString())"
    
    // Build request
    var request = URLRequest(url: URL(string: endpoint)!)
    request.httpMethod = "POST"
    
    // Set headers
    request.setValue(contentType, forHTTPHeaderField: "Content_Type")
    request.setValue(authorization, forHTTPHeaderField: "Authorization")
    
    // Set body
    request.httpBody = requestBodyCompomnents.query?.data(using: .utf8)
    
    // Make request
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard error == nil, let data = data else { return }
        
        // Decode response
        do {
            let jsonResponse = try JSONDecoder().decode(AccessTokenResponse.self, from: data)
            let defaults = UserDefaults.standard
            
            // Store refresh token
            defaults.set(jsonResponse.refresh_token, forKey: "SpotifyRefreshToken")
            defaults.setValue(jsonResponse.access_token, forKey: "SpotifyAccessToken")
        } catch {
            print("ERROR: \(error)")
        }
    }
    
    task.resume()
}

func refreshAccessToken() {
    let endpoint = "https://accounts.spotify.com/api/token"
    let grantType = "refresh_token"
    let refreshToken = UserDefaults.standard.string(forKey: "SpotifyRefreshToken")
    
    var requestBodyCompomnents = URLComponents()
    requestBodyCompomnents.queryItems =
    [
        .init(name: "grant_type", value: grantType),
        .init(name: "refresh_token", value: refreshToken)
    ]
    
    // Define headers
    let contentType = "application/x-www-form-urlencoded"
    let authorization = "Basic \((UserSecrets.CLIENT_ID + ":" + UserSecrets.CLIENT_SECRET).data(using: .utf8)!.base64EncodedString())"
    
    // Build request
    var request = URLRequest(url: URL(string: endpoint)!)
    request.httpMethod = "POST"
    
    // Set headers
    request.setValue(contentType, forHTTPHeaderField: "Content_Type")
    request.setValue(authorization, forHTTPHeaderField: "Authorization")
    
    // Set body
    request.httpBody = requestBodyCompomnents.query?.data(using: .utf8)
    
    // Make request
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard error == nil, let data = data else { return }
        
        // Decode response
        do {
            let jsonResponse = try JSONDecoder().decode(RefreshTokenResponse.self, from: data)
            print("Refreshed Access Token")
            
            // Store access token
            let defaults = UserDefaults.standard
            defaults.setValue(jsonResponse.access_token, forKey: "SpotifyAccessToken")
        } catch {
            print("ERROR: \(error)")
        }
    }
    
    task.resume()
}

func makeRequst() {
    let endpoint = "https://api.spotify.com/v1/me/player/currently-playing"
    
    var request = URLRequest(url: URL(string: endpoint)!)
    request.setValue("Bearer \(UserDefaults.standard.string(forKey: "SpotifyAccessToken") ?? "")", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content_Type")
    
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        
        guard error == nil, let data = data else { return }
        
        do {
            let jsonResponse = try JSONDecoder().decode(CurrentlyPlayingResponse.self, from: data)
            
            let songName = jsonResponse.item.name
            let artistName = jsonResponse.item.artists[0].name
            let album = jsonResponse.item.album.name
            
            print("You are listening to \"\(songName)\" by \"\(artistName)\" on the album \"\(album)\"")
            
            writeData(nameString: "\(album) - \(songName)")
            
            
        } catch {
            print("ERROR: \(error)")
        }
        
    }
    
    task.resume()
}

func writeData(nameString: String, format: String = "") {
    let filename = getDocumentsDirectory().appendingPathComponent("Snip.txt")
    
    do {
        try nameString.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
    } catch {
        // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
    }
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
