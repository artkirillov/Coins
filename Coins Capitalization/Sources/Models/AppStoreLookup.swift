//
//  AppStoreLookup.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 14.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

struct AppStoreLookup: Decodable {
    
    struct Results: Decodable {
        let appID: Int
        let currentVersionReleaseDate: String
        let minimumOSVersion: String
        let version: String
        
        private enum CodingKeys: String, CodingKey {
            case currentVersionReleaseDate
            case minimumOSVersion           = "minimumOsVersion"
            case appID                      = "trackId"
            case version
        }
    }
    
    let resultCount: Int
    let results: [Results]
}

