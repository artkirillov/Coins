//
//  PortfolioViewController.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 09.02.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class PortfolioViewController: UIViewController {
    
    // MARK: - Public Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items.sort(by: {$0.currentTotalCost > $1.currentTotalCost })
        
        tableView.tableFooterView = UIView()
        tableHeaderView = tableView.tableHeaderView as? PortfolioTableHeaderView
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.refreshControl?.endRefreshing()
        updateInfo()
    }
    
    @objc func updateData() {
        updateInfo()
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        let maxFreeVolume = Storage.maxPortfolioVolume()
        
        if items.count < maxFreeVolume {
            if let controller = storyboard?.instantiateViewController(withIdentifier: "AddCoinViewController") as? AddCoinViewController {
                controller.delegate = self
                present(controller, animated: true, completion: nil)
            }
        } else if maxFreeVolume == 3 {
            if let controller = storyboard?.instantiateViewController(withIdentifier: "AlertViewController") as? AlertViewController {
                controller.header = NSLocalizedString("Free trial alert", comment: "")
                controller.message = NSLocalizedString("Free trial message", comment: "")
                controller.image = #imageLiteral(resourceName: "review")
                
                controller.addAction(
                    title: NSLocalizedString("Go to AppStore", comment: ""),
                    handler: { [weak controller] in
                        if let appId = Storage.appId(), let url = URL(string: "https://itunes.apple.com/app/id\(appId)") {
                            UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                                Storage.save(maxPortfolioVolume: 5)
                                controller?.dismiss(animated: true, completion: nil)
                            })
                        } else if let url = URL(string: "https://www.apple.com/itunes/") {
                            UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                                Storage.save(maxPortfolioVolume: 5)
                                controller?.dismiss(animated: true, completion: nil)
                            })
                        }
                })
                
                controller.addAction(
                    title: NSLocalizedString("Cancel", comment: ""),
                    handler: { [weak controller] in controller?.dismiss(animated: true, completion: nil) })
                
                present(controller, animated: true, completion: nil)
            }
        } else {
            if let controller = storyboard?.instantiateViewController(withIdentifier: "AlertViewController") as? AlertViewController {
                controller.header = NSLocalizedString("Pro alert", comment: "")
                controller.image = #imageLiteral(resourceName: "check")
                
                var message: String = ""
                var okButtonTitle: String = ""
                var cancelButtonTitle: String = ""
                if let product = storeManager.unlimitedPortfolioProduct, storeManager.canMakePayments() {
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = .currency
                    numberFormatter.locale = product.priceLocale
                    let formattedPrice = numberFormatter.string(from: product.price) ?? "\(product.price)"
                    
                    message = NSLocalizedString("Pro message and payment", comment: "") + " \(formattedPrice)."
                    okButtonTitle = NSLocalizedString("Let's try it", comment: "")
                    cancelButtonTitle = NSLocalizedString("No, thanks", comment: "")
                } else {
                    message = NSLocalizedString("Pro message", comment: "")
                    okButtonTitle = NSLocalizedString("Ok", comment: "")
                    cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
                }
                
                controller.message = message
                
                controller.addAction(
                    title: okButtonTitle,
                    handler: { [weak self, weak controller] in
                        self?.storeManager.unlimitedPortfolioProduct.flatMap { self?.storeManager.makePayment(with: $0) }
                        controller?.dismiss(animated: true, completion: nil)
                })
                
                controller.addAction(
                    title: cancelButtonTitle,
                    handler: { [weak controller] in
                        controller?.dismiss(animated: true, completion: nil)
                })
                
                present(controller, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var tableView: UITableView!
    private var tableHeaderView: PortfolioTableHeaderView?
    
    private var items: [Asset] = Storage.assets() ?? [] {
        didSet {
            items.sort(by: {$0.currentTotalCost > $1.currentTotalCost })
        }
    }
    
    private let storeManager = StoreManager()
    
}

// MARK: - AddCoinViewControllerDelegate

extension PortfolioViewController: AddCoinViewControllerDelegate {
    func addCoinViewController(controller: AddCoinViewController, didAdd asset: Asset) {
        updateInfo()
    }
}

// MARK: - UITableViewDataSource

extension PortfolioViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssetCell", for: indexPath) as! AssetTableViewCell
        cell.configure(asset: items[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension PortfolioViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "CoinDetailsViewController") as? CoinDetailsViewController, let cell = tableView.cellForRow(at: indexPath) {
            controller.symbol = items[indexPath.row].symbol
            controller.name = items[indexPath.row].name
            
            let height = cell.frame.height
            let width = view.frame.width * height / view.frame.height
            let origin = view.convert(cell.frame.origin, from: tableView)
            let x = (cell.frame.width - width) / 2
            let originFrame = CGRect(x: x, y: origin.y, width: width, height: height)
            controller.originFrame = originFrame
            
            present(controller, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        items.remove(at: indexPath.row)
        tableView.reloadData()
        var currentValue: Double = 0.0
        var value: Double = 0.0
        items.forEach {
            currentValue += $0.currentTotalCost
            value += $0.totalCost
        }
        tableHeaderView?.configure(total: currentValue, value: value, currentValue: currentValue)
        Storage.save(assets: items)
    }
}

// MARK: - Updating table

private extension PortfolioViewController {
    
    // MARK: - Private Methods
    
    func updateInfo() {
        
        items = Storage.assets() ?? []
        
        if items.isEmpty {
            let noItemsLabel = UILabel()
            noItemsLabel.text = NSLocalizedString("You haven't added any assets to the portfolio", comment: "")
            noItemsLabel.numberOfLines = 0
            noItemsLabel.textColor = .lightGray
            noItemsLabel.textAlignment = .center
            tableView.backgroundView = noItemsLabel
        } else {
            tableView.backgroundView = nil
        }
        tableView.reloadData()
        
        var currentValue: Double = 0.0
        var value: Double = 0.0
        items.forEach {
            currentValue += $0.currentTotalCost
            value += $0.totalCost
        }
        tableHeaderView?.configure(total: currentValue, value: value, currentValue: currentValue)
        tableView.refreshControl?.endRefreshing()
    }
}
