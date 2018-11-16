//
//  Storage.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 01.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import Foundation

final class Storage {
    
    // MARK: - Public Nested
    
    struct Filename {
        static let coins  = "Coins.txt"
        static let assets = "Assets.txt"
    }
    
    struct UserDefaultsKeys {
        static let maxPortfolioVolume  = "maxPortfolioVolume"
        static let appId               = "appId"
        static let favoriteCoins       = "favoriteCoins"
    }
    
    // MARK: - Public Methods
    
    /// Gets AppStore appId from storage
    static func appId() -> Int? {
        let appId = UserDefaults.standard.integer(forKey: UserDefaultsKeys.appId)
        return appId != 0 ? appId : nil
    }
    
    /// Gets max portfolio volume from storage
    static func maxPortfolioVolume() -> Int {
        let maxPortfolioVolume = UserDefaults.standard.integer(forKey: UserDefaultsKeys.maxPortfolioVolume)
        return maxPortfolioVolume != 0 ? maxPortfolioVolume : 3
    }
    
    /// Gets favorite coins from storage
    static func favoriteCoins() -> [String] {
        if let favoriteCoins = UserDefaults.standard.array(forKey: UserDefaultsKeys.favoriteCoins) as? [String] {
            return favoriteCoins
        } else {
            return []
        }
    }
    
    /// Gets coins from storage
    static func coins() -> [Coin]? {
        return get(from: Filename.coins)
    }
    
    /// Gets assets from storage
    static func assets() -> [Asset]? {
        return get(from: Filename.assets)
    }
    
    /// Saves AppStore appId to storage
    static func save(appId: Int) {
        UserDefaults.standard.set(appId, forKey: UserDefaultsKeys.appId)
    }
    
    /// Saves max portfolio volume to storage
    static func save(maxPortfolioVolume: Int) {
        UserDefaults.standard.set(maxPortfolioVolume, forKey: UserDefaultsKeys.maxPortfolioVolume)
    }
    
    /// Saves new favorite coins to storage
    static func save(favoriteCoins: [String]) {
        UserDefaults.standard.set(favoriteCoins, forKey: UserDefaultsKeys.favoriteCoins)
    }
    
    /// Saves coins to storage
    static func save(coins: [Coin]) {
        save(coins, in: Filename.coins)
    }
    
    /// Saves assets to storage
    static func save(assets: [Asset]) {
        save(assets, in: Filename.assets)
    }
    
    /// Generic method for saving API data to cache
    static func saveToCache(for endPoint: API.EndPoint, data: Data) {
        guard let string = String(data: data, encoding: String.Encoding.utf8) else { return }
        DispatchQueue.global().async {
            if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let filepath = path.appendingPathComponent(filename(for: endPoint))
                do {
                    try string.write(to: filepath, atomically: true, encoding: String.Encoding.utf8)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    /// Generic method for getting API data from cache
    static func getCache<T: Decodable>(for endPoint: API.EndPoint) -> T? {
        if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filepath = path.appendingPathComponent(filename(for: endPoint))
            
            if let lastUpdate = fileModificationDate(url: filepath),
                isExpired(lastUpdate: lastUpdate, lagInSeconds: endPoint.cacheExpirationInSeconds) {
                return nil
            }
            
            do {
                let data = try Data(contentsOf: filepath)
                let jsonDecoder = JSONDecoder()
                
                do {
                    let object = try jsonDecoder.decode(T.self, from: data)
                    return object
                } catch {
                    print(error)
                }
            } catch {
                print(error)
            }
        }
        return nil
    }
    
    // MARK: - Private Methods
    
    /// Generic method for saving encodable objects to files
    private static func save<T: Encodable>(_ object: T, in filename: String) {
        
        let jsonEncoder = JSONEncoder()
        
        do {
            let data = try jsonEncoder.encode(object)
            let string = String(data: data, encoding: String.Encoding.utf8)
            
            if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let filepath = path.appendingPathComponent(filename)
                do {
                    try string?.write(to: filepath, atomically: true, encoding: String.Encoding.utf8)
                } catch {
                    print(error)
                }
            }
        } catch {
            print(error)
        }
    }
    
    /// Generic method for getting decodable objects from files
    private static func get<T: Decodable>(from filename: String) -> T? {
        
        if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filepath = path.appendingPathComponent(filename)
            do {
                let data = try Data(contentsOf: filepath)
                let jsonDecoder = JSONDecoder()
                
                do {
                    let object = try jsonDecoder.decode(T.self, from: data)
                    return object
                } catch {
                    print(error)
                }
            } catch {
                print(error)
            }
        }
        return nil
    }
    
    private static func filename(for endPoint: API.EndPoint) -> String {
        var filename = ""
        switch endPoint {
        case .ticker:     filename = "TickersCache.txt"
        case .globalData: filename = "GlobalDataCahce.txt"
        case .chart(let type, let symbol): filename = "\(type.rawValue)ChartDataCache\(symbol).txt"
        case .appStore:   filename = "AppStoreLookUp.txt"
        }
        return filename
    }
    
    private static func fileModificationDate(url: URL) -> Date? {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: url.path)
            return attr[FileAttributeKey.modificationDate] as? Date
        } catch {
            return nil
        }
    }
    
    private static func isExpired(lastUpdate: Date, lagInSeconds: Int) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.second], from: lastUpdate, to: Date())
        return (components.second ?? 0) > lagInSeconds
    }
}
