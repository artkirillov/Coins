//
//  CoinItemTableViewCell.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 03.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class CoinItemTableViewCell: UITableViewCell {
    
    // MARK: - Public Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = ""
        nameLabel.text = ""
    }
    
    func configure(coin: Coin) {
        symbolLabel.text = coin.symbol
        nameLabel.text = coin.name
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var symbolLabel: UILabel!
    @IBOutlet private var nameLabel: UILabel!
    
}
