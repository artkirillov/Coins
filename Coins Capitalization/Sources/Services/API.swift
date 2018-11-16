//
//  APIManager.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 28.01.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import Foundation

final class API {
    
    // MARK: - Public Nested
    
    struct CashKeys {
        static var lastUpdate = "lastUpdate"
    }
    
    enum EndPoint {
        
        case ticker
        case globalData
        case chart(type: ChartType, symbol: String)
        case appStore
        
        enum ChartType: String {
            case all         = ""
            case year        = "365day"
            case halfYear    = "180day"
            case threeMonths = "90day"
            case month       = "30day"
            case week        = "7day"
            case day         = "1day"
        }
        
        var urlComponents: URLComponents? {
            switch self {
            case .ticker:                      return URLComponents(string: "https://api.coinmarketcap.com/v1/ticker/")
            case .globalData:                  return URLComponents(string: "https://api.coinmarketcap.com/v1/global/")
            case .chart(let type, let symbol):
                if type == .all {              return URLComponents(string: "https://coincap.io/history/\(symbol)") }
                else {                         return URLComponents(string: "https://coincap.io/history/\(type.rawValue)/\(symbol)") }
            case .appStore:                    return URLComponents(string: "https://itunes.apple.com/lookup")
            }
        }
        
        var parameters: [String: String]? {
            switch self {
            case .ticker:     return ["limit": "0"]
            case .appStore:   return ["bundleId": Bundle.main.bundleIdentifier ?? ""]
            default: return nil
            }
        }
        
        var cacheExpirationInSeconds: Int {
            switch self {
            case .ticker, .globalData: return 10
            case .chart:               return 30
            case .appStore:            return Int.max
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Requests coins data from Coin Market Cap API
    static func requestCoinsData(success: @escaping ([Ticker]) -> Void, failure: @escaping (Error) -> Void) {
        request(endpoint: .ticker, parameters: EndPoint.ticker.parameters, success: success, failure: failure)
    }
    
    /// Requests global market info from Coin Market Cap API
    static func requestGlobalData(success: @escaping (GlobalData) -> Void, failure: @escaping (Error) -> Void) {
        request(endpoint: .globalData, success: success, failure: failure)
    }
    
    /// Requests chart data from Coin Cap IO API
    static func requestChartData(type: EndPoint.ChartType, for symbol: String,
                                 success: @escaping (ChartData) -> Void, failure: @escaping (Error) -> Void) {
        request(endpoint: .chart(type: type, symbol: symbol), success: success, failure: failure)
    }
    
    /// Requests AppStore appId
    static func requestAppStoreData(success: @escaping (AppStoreLookup) -> Void, failure: @escaping (Error) -> Void) {
        request(endpoint: .appStore, parameters: EndPoint.appStore.parameters, success: success, failure: failure)
    }
    
    // MARK: - Private Methods
    
    /// Generic request method
    private static func request<T: Decodable>(
        endpoint: EndPoint,
        parameters: [String: String]? = nil,
        success: @escaping (T) -> Void,
        failure: @escaping (Error) -> Void
        )
    {
        if let cahcedData: T = Storage.getCache(for: endpoint) {
            success(cahcedData)
            return
        }
        
        guard var urlComponents = endpoint.urlComponents else { return }
        
        if let parameters = parameters {
            urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents.url else { return }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            guard error == nil else {
                print("ERROR: \(error!.localizedDescription)")
                failure(error!)
                return
            }
            
            guard let data = data else {
                print("NO DATA")
                return
            }
            
            Storage.saveToCache(for: endpoint, data: data)
            
            let jsonDecoder = JSONDecoder()
            
            do {
                let object = try jsonDecoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    success(object)
                }
            } catch {
                DispatchQueue.main.async {
                    failure(error)
                }
            }
        }
        
        task.resume()
    }
}
