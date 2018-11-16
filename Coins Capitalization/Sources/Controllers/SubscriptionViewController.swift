//
//  SubscriptionViewController.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 14.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class SubscriptionViewController: UIViewController {
    
    // MARK: - Public Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        billedMonthlyButton.layer.cornerRadius = 4.0
        billedAnnuallyButton.layer.cornerRadius = 4.0
        
        billedMonthlyButton.backgroundColor = Colors.controlDisabled
        billedAnnuallyButton.backgroundColor = Colors.controlEnabled
    }
    
    @IBAction func billedMonthlyButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func billedAnnuallyButtonTapped(_ sender: UIButton) {
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private weak var billedMonthlyButton: UIButton!
    @IBOutlet private weak var billedAnnuallyButton: UIButton!
    
}
