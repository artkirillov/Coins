//
//  GlobalData.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 28.01.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

struct GlobalData: Codable {
    
    var totalMarketCapUSD: Double
    var total24hVolumeUSD: Double
    var bitcoinPercentageOfMarketCap: Double
    var activeCurrencies: Int
    var activeAssets: Int
    var activeMarkets: Int
    var lastUpdated: Int
    
    private enum CodingKeys: String, CodingKey {
        
        case totalMarketCapUSD            = "total_market_cap_usd"
        case total24hVolumeUSD            = "total_24h_volume_usd"
        case bitcoinPercentageOfMarketCap = "bitcoin_percentage_of_market_cap"
        case activeCurrencies             = "active_currencies"
        case activeAssets                 = "active_assets"
        case activeMarkets                = "active_markets"
        case lastUpdated                  = "last_updated"
    }
}
