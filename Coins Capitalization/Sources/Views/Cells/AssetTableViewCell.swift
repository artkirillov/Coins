//
//  AssetTableViewCell.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 11.02.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class AssetTableViewCell: UITableViewCell {
    
    // MARK: - Public Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 4.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
        amountLabel.text = ""
        totalCostLabel.text = ""
        profitLabel.text = ""
    }
    
    func configure(asset: Asset) {
        
        nameLabel.text = asset.name
        Formatter.formatAmount(label: amountLabel, value: asset.totalAmount, symbol: asset.symbol)
        
        guard asset.currentPrice != nil else {
            totalCostLabel.text = NSLocalizedString("No info", comment: "")
            profitLabel.text = NSLocalizedString("No info", comment: "")
            totalCostLabel.textColor = .lightGray
            profitLabel.textColor = .lightGray
            return
        }
        
        let currentTotalCost = asset.currentTotalCost
        Formatter.formatCost(label: totalCostLabel, value: currentTotalCost)
        Formatter.formatProfit(label: profitLabel, firstValue: asset.totalCost, lastValue: currentTotalCost)
    }
    
    // MARK: - Private Properties
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var amountLabel: UILabel!
    @IBOutlet private var totalCostLabel: UILabel!
    @IBOutlet private var profitLabel: UILabel!
    
}

fileprivate extension AssetTableViewCell {
    
    func setNumber(label: UILabel, value: Double, prefix: String? = nil, suffix: String? = nil, maximumFractionDigits: Int = 0) {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = maximumFractionDigits
        
        guard let text = numberFormatter.string(from: value as NSNumber) else {
            label.text = nil
            return
        }
        
        label.text = "\(prefix ?? "")\(text)\(suffix ?? "")"
    }
    
}
