//
//  Snip.swift
//  macOS SNIP
//
//  Created by Timo Wesselmann on 06.03.22.
//

import Foundation
import SwiftUI

class Snip: ObservableObject {
    @AppStorage(UserDefaultsKeys.refreshToken) var refreshToken: String = ""
    @AppStorage(UserDefaultsKeys.accessToken) var accessToken: String = ""
    var timer: Timer? = nil
    var currentSong: String = ""
    @Published var isLoggedIn: Bool = false
    
    init() {
        if !UserDefaults.standard.bool(forKey: UserDefaultsKeys.loggedIn) {
            print("User not logged in!")
            self.requestUserAuthentication()
        } else {
            print("User alread logged in!")
            self.isLoggedIn = true
            self.refreshAccessToken()
            self.registerTimer()
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
        
        NSWorkspace.shared.open(url)
        
    }

    func requestAccessToken() {
        
        let endpoint = "https://accounts.spotify.com/api/token"
        let grantType = "authorization_code"
        let code = "AQCvrW6QURbmkxbaNy_lfTM1g0sa3rZttS8kRFnEsgjonTrshIbp7qfnkA8hTm-QsN_6bJXIvz8mHVo02VFEo9ohNBSDxbK4BrjqM3ywZjDR_vycYxDafEPQjHTSShCEOPnEBY2Y4MG1uBtLFZIxFSUR_hK5cRbLf-Jb3EIlu4EEM6fucymRWynf94p_2ymmmeu5Ehg7IgY"
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
            guard error == nil, let data = data, let response = response as? HTTPURLResponse else { return }
            
            switch response.statusCode {
            case 200:
                // Decode response
                do {
                    let jsonResponse = try JSONDecoder().decode(AccessTokenResponse.self, from: data)
                    let defaults = UserDefaults.standard
                    
                    // Store refresh token
                    self.accessToken = jsonResponse.access_token
                    self.refreshToken = jsonResponse.refresh_token
                    DispatchQueue.main.async {
                        self.isLoggedIn = true
                    }
                    defaults.setValue(true, forKey: UserDefaultsKeys.loggedIn)
                    self.registerTimer()
                } catch {
                    print("ERROR: \(error)")
                }
            case 400:
                print("Authorization code expired")
            default:
                print("Unhadled status code: \(response.statusCode)")
                print(String(data: data, encoding: .utf8) as Any)
            }
        }
        
        task.resume()
    }

    func refreshAccessToken() {
        let endpoint = "https://accounts.spotify.com/api/token"
        let grantType = "refresh_token"
        
        var requestBodyCompomnents = URLComponents()
        requestBodyCompomnents.queryItems =
        [
            .init(name: "grant_type", value: grantType),
            .init(name: "refresh_token", value: self.refreshToken)
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
                DispatchQueue.main.async {
                    self.accessToken = jsonResponse.access_token
                }
            } catch {
                print("ERROR: \(error)")
            }
        }
        
        task.resume()
    }

    func makeRequst() {
        
        // Define endpoint
        let endpoint = "https://api.spotify.com/v1/me/player/currently-playing"
        
        // Build request
        var request = URLRequest(url: URL(string: endpoint)!)
        
        // Set headers
        request.setValue("Bearer \(UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken) ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content_Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard error == nil, let data = data, let response = response as? HTTPURLResponse else { return }
            
            // Handle common status codes
            switch response.statusCode {
                
                // Successful request | Write data
                case 200:
                    do {
                        let jsonResponse = try JSONDecoder().decode(CurrentlyPlayingResponse.self, from: data)
                        
                        let songName = jsonResponse.item.name
                        let artistName = jsonResponse.item.artists[0].name
                        let album = jsonResponse.item.album.name
                        let imageUrl = jsonResponse.item.album.images[0].url
                        
                        if self.currentSong != "\(artistName) - \(songName)" {
                            self.currentSong = "\(artistName) - \(songName)"
                            print("You are listening to \"\(songName)\" by \"\(artistName)\" on the album \"\(album)\"")
                            self.writeText(nameString: "\(artistName) - \(songName)    |    ")
                            self.downloadImage(imageUrl: imageUrl)
                        }
                                                
                    } catch {
                        print("ERROR: \(error)")
                    }
                
                // Successful request | Currently no song playing
                case 204:
                    if self.currentSong != "" {
                        print("No Content: No song playing!")
                        self.currentSong = ""
                        self.writeText(nameString: "")
                    }
                
                // Unsuccessful request | Invalid Access Token
                case 401:
                    print("STATUS CODE: \(response.statusCode)")
                    print("Regenerating Access Token")
                    self.refreshAccessToken()
                
                    // Start another request after 1 second
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.makeRequst()
                    }
                
                // Unsuccessful request | Unusual response
                default:
                    print("Unusual status code: \(response.statusCode)")
                    print(String(data: data, encoding: .utf8) as Any)
                }
        }
        
        task.resume()
    }
    
    func logOut() {
        let defaults = UserDefaults.standard
        defaults.setValue(false, forKey: UserDefaultsKeys.loggedIn)
        self.isLoggedIn = false
        self.refreshToken = ""
        self.accessToken = ""
        self.timer?.invalidate()
    }
    
    func logIn() {
        
    }
    
    func registerTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
            self.makeRequst()
        }
    }
    
    func writeText(nameString: String, format: String = "") {
        let filename = self.getDocumentsDirectory().appendingPathComponent("Snip.txt")
        
        do {
            try nameString.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }
    }
    
    func downloadImage(imageUrl: String) {
        let filename = self.getDocumentsDirectory().appendingPathComponent("Snip_Artwork.jpeg")
        let url = URL(string: imageUrl)!
        
        // TODO: Implement...
        
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

}
