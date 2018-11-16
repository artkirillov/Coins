//
//  ArticleTableViewCell.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 20.06.2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class ArticleTableViewCell: UITableViewCell {
    
    // MARK: - Public Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
        logoView.layer.cornerRadius = 4.0
        containerView.layer.cornerRadius = 4.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    func reset() {
        logoView.image = nil
        titleLabel.text = ""
        descriptionLabel.text = ""
        updatedLabel.text = ""
    }
    
    func configure(article: Article) {
        logoView.image = article.source.image
        titleLabel.text = article.title
        descriptionLabel.text = article.description
        
        if let date = article.publishedAt {
            let components = Calendar.current.dateComponents([.minute, .hour, .day], from: date, to: Date())
            let agoString = NSLocalizedString("ago", comment: "")
            
            if let days = components.day, days > 0 {
                updatedLabel.text = "\(days) \(Formatter.days(for: days)) \(agoString)"
            } else if let hours = components.hour, hours > 0 {
                updatedLabel.text = "\(hours) \(Formatter.hours(for: hours)) \(agoString)"
            } else if let minutes = components.minute, minutes > 0 {
                updatedLabel.text = "\(minutes) \(Formatter.minutes(for: minutes)) \(agoString)"
            } else {
                updatedLabel.text = nil
            }
        }
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private var logoView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var updatedLabel: UILabel!
    
}
