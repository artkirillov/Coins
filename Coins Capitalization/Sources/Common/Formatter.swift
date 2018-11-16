//
//  Formatter.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 12.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit
import Foundation

final class Formatter {
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static func format(_ number: Double, maximumFractionDigits: Int = 2) -> String? {
        numberFormatter.maximumFractionDigits = maximumFractionDigits
        return numberFormatter.string(from: abs(number) as NSNumber)
    }
    
    static func formatAmount(label: UILabel, value: Double, symbol: String, maximumFractionDigits: Int = 10) {
        if let amount = Formatter.format(value, maximumFractionDigits: maximumFractionDigits) {
            label.text = "\(amount) \(symbol)"
        }
    }
    
    static func formatCost(label: UILabel, value: Double, maximumFractionDigits: Int = 2) {
        if let cost = Formatter.format(value, maximumFractionDigits: maximumFractionDigits) { label.text = "$\(cost)" }
    }
    
    static func formatProfit(label: UILabel, firstValue: Double?, lastValue: Double?, maximumFractionDigits: Int = 2) {
        guard let firstValue = firstValue, let lastValue = lastValue, firstValue != 0 || lastValue != 0 else {
            label.text = ""
            return
        }
        
        let absoluteProfit = lastValue - firstValue
        let relativeProfit = absoluteProfit / firstValue * 100
        
        guard let profitText = Formatter.format(absoluteProfit, maximumFractionDigits: maximumFractionDigits),
            let percentText = Formatter.format(relativeProfit) else {
            label.text = ""
            return
        }
        
        if absoluteProfit > 0 {
            label.text = "↑ $\(profitText) (\(percentText)%)"
            label.textColor = Colors.positiveGrow
        } else if absoluteProfit < 0 {
            label.text = "↓ $\(profitText) (\(percentText)%)"
            label.textColor = Colors.negativeGrow
        }
    }
    
    static func days(for number: Int) -> String {
        return localizedNumber(for: number, keys: ("day", "severalDays", "manyDays"))
    }
    
    static func hours(for number: Int) -> String {
        return localizedNumber(for: number, keys: ("hour", "severalHours", "manyHours"))
    }
    
    static func minutes(for number: Int) -> String {
        return localizedNumber(for: number, keys: ("minute", "severalMinutes", "manyMinutes"))
    }
    
    static func localizedNumber(for number: Int, keys: (one: String, several: String, many: String)) -> String {
        
        if (11...14).contains(number) { return NSLocalizedString(keys.many, comment: "") }
        
        switch number % 10 {
        case 1: return NSLocalizedString(keys.one, comment: "")
        case 2, 3, 4: return NSLocalizedString(keys.several, comment: "")
        default: return NSLocalizedString(keys.many, comment: "")
        }
    }
    
}
