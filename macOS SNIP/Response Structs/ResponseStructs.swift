//
//  ResponseStructs.swift
//  macOS SNIP
//
//  Created by Timo Wesselmann on 05.03.22.
//

struct AccessTokenResponse: Codable {
    let access_token: String
    let token_type: String
    let scope: String
    let expires_in: Int
    let refresh_token: String
}

struct RefreshTokenResponse: Codable {
    let access_token: String
    let token_type: String
    let scope: String
    let expires_in: Int
}

struct CurrentlyPlayingResponse: Codable {
    let item: Item
    
    struct Item: Codable {
        let album: Album
        let name: String
        let artists: [Artist]
        
        struct Album: Codable {
            let name: String
            let images: [Image]
            
            struct Image: Codable {
            let height: Int
            let url: String
            let width:Int
            }
        }
        
        struct Artist: Codable {
            let name: String
        }
    }
}
