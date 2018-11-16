//
//  ChartData.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 04.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

struct ChartData: Codable {
    
    var marketCap: [[Double]]
    var price: [[Double]]
    var volume: [[Double]]
    
    private enum CodingKeys: String, CodingKey {
        case marketCap = "market_cap"
        case price
        case volume
    }
}

