//
//  Asset.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 11.02.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

struct Asset: Codable {
    
    var name: String
    var symbol: String
    var volume: [Volume]
    var currentPrice: Double?
    
    var totalAmount: Double {
        return volume.reduce(0.0) { $0 + $1.amount }
    }
    
    var totalCost: Double {
        return volume.reduce(0.0) { $0 + $1.amount * $1.price }
    }
    
    var currentTotalCost: Double {
        return volume.reduce(0.0) { $0 + $1.amount * (currentPrice ?? 0) }
    }
    
}

struct Volume: Codable {
    
    var amount: Double
    var price: Double
}
