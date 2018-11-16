//
//  CoinDetailsViewController.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 04.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class CoinDetailsViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var symbol: String?
    var name: String?
    var isFavorite: Bool = false {
        didSet {
            favoriteButton.setImage(isFavorite ? #imageLiteral(resourceName: "heart_full") : #imageLiteral(resourceName: "heart_empty"), for: .normal)
        }
    }
    
    weak var delegate: ReduceCoinViewControllerDelegate?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // Custom Transition parameters
    
    var originFrame = CGRect.zero
    
    // MARK: Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = name
        segmentedControl.selectedIndex = 0
        noDataView.layer.cornerRadius = noDataView.bounds.height / 2
        
        addButton.layer.cornerRadius = 4.0
        reduceButton.layer.cornerRadius = 4.0
        reduceButton.setTitleColor(Colors.controlTextEnabled, for: .normal)
        reduceButton.setTitleColor(Colors.controlTextDisabled, for: .disabled)
        
        animation.duration = 0.2
        animation.type = kCATransitionFade
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        noDataView.isHidden = true
        
        isFavorite = Storage.favoriteCoins().contains(symbol ?? "")
        
        requestData(for: .day)
        updateAssetInfo()
        
        transitioningDelegate = self
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        isFavorite = !isFavorite
        feedBackGenerator.impactOccurred()
        
        var favoriteCoins = Storage.favoriteCoins()
        
        if isFavorite {
            symbol.flatMap { favoriteCoins.append($0) }
        } else {
            favoriteCoins = favoriteCoins.filter { $0 != symbol }
        }
        
        Storage.save(favoriteCoins: favoriteCoins)
    }
    
    @IBAction func changeChartType(_ sender: SegmentedControl) {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        noDataView.isHidden = true
        switch sender.selectedIndex {
        case 0: requestData(for: .day)
        case 1: requestData(for: .week)
        case 2: requestData(for: .month)
        case 3: requestData(for: .threeMonths)
        case 4: requestData(for: .halfYear)
        case 5: requestData(for: .year)
        case 6: requestData(for: .all)
        default: break
        }
    }
    
    @IBAction func reduceButtonTapped(_ sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "ReduceCoinViewController") as? ReduceCoinViewController,
            let asset = asset {
            controller.delegate = self
            controller.asset = asset
            present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "AddCoinViewController") as? AddCoinViewController {
            controller.delegate = self
            controller.coin = Storage.coins()?.first { $0.symbol == symbol }
            present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: - Private properties
    
    private var asset: Asset?
    private let animation = CATransition()
    private let feedBackGenerator = UIImpactFeedbackGenerator()
    
    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var changeLabel: UILabel!
    @IBOutlet private weak var chartView: ChartView!
    @IBOutlet private weak var noDataView: UIView!
    @IBOutlet private weak var segmentedControl: SegmentedControl!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var costLabel: UILabel!
    @IBOutlet private weak var profitLabel: UILabel!
    @IBOutlet private weak var reduceButton: UIButton!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var infoContainer: UIView!
    @IBOutlet private weak var infoContainerHeightConstraint: NSLayoutConstraint!
}

// MARK: - AddCoinViewControllerDelegate

extension CoinDetailsViewController: AddCoinViewControllerDelegate {
    func addCoinViewController(controller: AddCoinViewController, didAdd asset: Asset) {
        updateAssetInfo()
    }
}

// MARK: - ReduceCoinViewControllerDelegate

extension CoinDetailsViewController: ReduceCoinViewControllerDelegate {
    func reduceCoinViewController(controller: ReduceCoinViewController, didChange asset: Asset) {
        updateAssetInfo()
    }
}

// MARK: - Network Requests

private extension CoinDetailsViewController {
    
    func requestData(for type: API.EndPoint.ChartType) {
        guard let symbol = symbol else { return }
        API.requestChartData(type: type, for: symbol,
                             success: { [weak self] chartData in
                                guard let slf = self else { return }
                                slf.chartView.layer.add(slf.animation, forKey: kCATransition)
                                slf.chartView.data = chartData.price.map { $0 }
                                slf.activityIndicator.stopAnimating()
                                slf.activityIndicator.isHidden = true
                                slf.noDataView.isHidden = true
                                
                                let prices = chartData.price
                                
                                Formatter.formatProfit(label: slf.changeLabel,
                                                       firstValue: prices[0][1],
                                                       lastValue: prices[prices.count - 2][1],
                                                       maximumFractionDigits: 5)
            },
                             failure: { [weak self] error in
                                guard let slf = self else { return }
                                slf.activityIndicator.stopAnimating()
                                slf.activityIndicator.isHidden = true
                                slf.noDataView.isHidden = false
                                slf.showErrorAlert(error)
        })
    }
    
    func updateAssetInfo() {
        asset = Storage.assets()?.first(where: { $0.symbol == symbol } )
        
        guard let symbol = symbol, let asset = asset else {
            showInfoContainer(false)
            reduceButton.isEnabled = false
            return
        }
        
        Formatter.formatCost(label: costLabel, value: asset.currentTotalCost)
        Formatter.formatAmount(label: amountLabel, value: asset.totalAmount, symbol: symbol)
        Formatter.formatProfit(label: profitLabel, firstValue: asset.totalCost, lastValue: asset.currentTotalCost)
        showInfoContainer(true)
        reduceButton.isEnabled = true
    }
    
    func showInfoContainer(_ show: Bool) {
        if show {
            infoContainer.isHidden = false
            infoContainerHeightConstraint.constant = 90
        } else {
            infoContainer.isHidden = true
            infoContainerHeightConstraint.constant = 0
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension CoinDetailsViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            return CustomViewControllerAnimator(duration: 0.2, isPresenting: true, originFrame: originFrame)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomViewControllerAnimator(duration: 0.2, isPresenting: false, originFrame: originFrame)
    }
}
