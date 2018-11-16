//
//  CoinsViewController.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 23.01.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class CoinsViewController: UIViewController {
    
    // MARK: - Public Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.leftViewMode = .always
        searchTextField.leftView = UIImageView(image: #imageLiteral(resourceName: "search"))
        
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(#imageLiteral(resourceName: "clear"), for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 25, height: 16)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(clearSearchTextField), for: .touchUpInside)
        searchTextField.rightView = clearButton
        searchTextField.rightViewMode = .always
        searchTextFieldClearButton = clearButton
        searchTextFieldClearButton?.isHidden = true
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        view.addSubview(activityIndicatorView)
        activityIndicator = activityIndicatorView
        activityIndicator?.center = view.center
        activityIndicator?.startAnimating()
        
        collectionView.register(TickerListCollectionViewCell.self, forCellWithReuseIdentifier: "TickerListCollectionViewCell")
        
        segmentControl.items = [NSLocalizedString("All", comment: "").uppercased(),
                                NSLocalizedString("Favorite", comment: "").uppercased()]
        segmentControl.thumb = .line
        segmentControl.thumbColor = .lightGray
        segmentControl.itemsFont = UIFont.systemFont(ofSize: 12)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestData()
    }
    
    @objc func updateData() {
        requestData()
    }
    
    @objc func clearSearchTextField() {
        searchTextField.text = nil
        searchTextFieldClearButton?.isHidden = true
        filteredItems = items
        filteredFavoriteItems = favoriteItems
        collectionView.reloadData()
        view.endEditing(true)
    }
    
    @IBAction func changeCoinList(_ sender: SegmentedControl) {
        collectionView.scrollToItem(at: IndexPath(row: sender.selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    func updateItems(withSearchText searchText: String) {
        
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            filteredItems = items
            filteredFavoriteItems = favoriteItems
            collectionView.reloadData()
            return
        }
        
        filteredItems = items
            .filter { $0.name.lowercased().range(of: searchText.lowercased()) != nil || $0.symbol.lowercased().range(of: searchText.lowercased()) != nil }
        filteredFavoriteItems = favoriteItems
            .filter { $0.name.lowercased().range(of: searchText.lowercased()) != nil || $0.symbol.lowercased().range(of: searchText.lowercased()) != nil }
        
        collectionView.reloadData()
    }
    
    func reset() {
        requestData()
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private weak var marketCapitalizationLabel: UILabel!
    @IBOutlet private weak var bitcoinDominanceLabel: UILabel!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var segmentControl: SegmentedControl!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var searchTextFieldClearButton: UIButton?
    private var activityIndicator: UIActivityIndicatorView?
    
    private var items: [Ticker] = []
    private var filteredItems: [Ticker] = []
    
    private var favoriteItems: [Ticker] = []
    private var filteredFavoriteItems: [Ticker] = []
    
    private var searchText = ""
}

// MARK: - UITextFieldDelegate

extension CoinsViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let textFieldText = textField.text else {
            updateItems(withSearchText: "")
            return true
        }
        
        searchText = string.isEmpty ? String(textFieldText.dropLast()) : textFieldText + string
        
        updateItems(withSearchText: searchText)
        searchTextFieldClearButton?.isHidden = (textFieldText + string).isEmpty
        return true
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchTextFieldClearButton?.isHidden = textField.text?.isEmpty ?? true
    }
    
}

// MARK: - UICollectionViewDataSource

extension CoinsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TickerListCollectionViewCell", for: indexPath) as! TickerListCollectionViewCell
        let emptyResultsText = !searchText.isEmpty ? NSLocalizedString("Can't find any coins", comment: "") : ""
        
        if indexPath.row == 0 {
            cell.configure(items: filteredItems, noItemsText: emptyResultsText)
        } else if indexPath.row == 1 {
            let noItemsText = favoriteItems.isEmpty ?
                NSLocalizedString("You haven't added any coins to favorites", comment: "") :
                emptyResultsText
            cell.configure(items: filteredFavoriteItems, noItemsText: noItemsText)
        }
        cell.delegate = self
        return cell
    }
}

// MARK: - UIScrollViewDelegate

extension CoinsViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        segmentControl.thumbProgress = scrollView.contentOffset.x / (scrollView.contentSize.width - collectionView.bounds.width)
    }
    
}

// MARK: - UICollectionViewDelegate

extension CoinsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
}

// MARK: - TickerListCollectionViewCellDelegate

extension CoinsViewController: TickerListCollectionViewCellDelegate {
    
    func tickerListCollectionViewCellDidRequestUpdate(cell: TickerListCollectionViewCell) {
        requestData()
    }
    
    func tickerListCollectionViewCell(cell: TickerListCollectionViewCell, didSelectRowAt index: Int, frame: CGRect) {
        if let row = collectionView.indexPath(for: cell)?.row,
            let controller = storyboard?.instantiateViewController(withIdentifier: "CoinDetailsViewController") as? CoinDetailsViewController {
            let tickers = row == 0 ? filteredItems : filteredFavoriteItems
            
            controller.symbol = tickers[index].symbol
            controller.name = tickers[index].name
            
            let height = frame.height
            let width = view.frame.width * height / view.frame.height
            let origin = view.convert(frame.origin, from: cell)
            let x = (frame.width - width) / 2
            let originFrame = CGRect(x: x, y: origin.y, width: width, height: height)
            controller.originFrame = originFrame
            
            present(controller, animated: true, completion: nil)
        }
    }
    
}

// MARK: - Network Requests

private extension CoinsViewController {
    
    func requestData() {
        API.requestCoinsData(
            success: { [weak self] tickers in
                let favoriteCoins = Storage.favoriteCoins()
                let favoriteTickers = tickers.filter { favoriteCoins.contains($0.symbol) }
                
                self?.items = tickers
                self?.favoriteItems = favoriteTickers
                
                if let searchText = self?.searchTextField.text, !searchText.isEmpty {
                    self?.updateItems(withSearchText: searchText)
                } else {
                    self?.filteredItems = tickers
                    self?.filteredFavoriteItems = favoriteTickers
                }
                
                self?.collectionView.reloadData()
                self?.activityIndicator?.stopAnimating()
                
                DispatchQueue.global().async {
                    let coins = tickers.map { Coin(id: $0.id, name: $0.name, symbol: $0.symbol, priceUSD: $0.priceUSD) }
                    Storage.save(coins: coins)
                    
                    var assets = Storage.assets() ?? []
                    assets.enumerated().forEach { index, asset in
                        if let coin = coins.first(where: { coin in return coin.symbol == asset.symbol }),
                            let priceUSD = coin.priceUSD {
                            assets[index].currentPrice = Double(priceUSD)
                        }
                    }
                    Storage.save(assets: assets)
                    
                    DispatchQueue.main.async {
                        if let tabBarController = self?.parent as? UITabBarController,
                            let portfolioViewController = tabBarController.viewControllers?[1] as? PortfolioViewController,
                            portfolioViewController.isViewLoaded {
                            portfolioViewController.updateData()
                        }
                    }
                }
            },
            failure: { [weak self] error in
                self?.stopAnimateActivity()
                self?.showErrorAlert(error)
        })
        
        API.requestGlobalData(
            success: { [weak self] globalData in
                
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                numberFormatter.maximumFractionDigits = 2
                
                if let text = numberFormatter.string(from: round(Double(globalData.totalMarketCapUSD) / 1000000000) as NSNumber) {
                    self?.marketCapitalizationLabel.text = "\(NSLocalizedString("Market Capitalization", comment: "")): $\(text)\(NSLocalizedString("B", comment: ""))"
                    self?.marketCapitalizationLabel.textAlignment = .left
                } else {
                    self?.marketCapitalizationLabel.text = NSLocalizedString("Coins", comment: "")
                }
                
                if let text = numberFormatter.string(from: globalData.bitcoinPercentageOfMarketCap as NSNumber) {
                    self?.bitcoinDominanceLabel.text = "\(NSLocalizedString("Bitcoin Dominance", comment: "")): \(text)%"
                } else {
                    self?.bitcoinDominanceLabel.text = nil
                }
            },
            failure: { [weak self] error in
                self?.stopAnimateActivity()
                self?.showErrorAlert(error)
        })
        
        API.requestAppStoreData(
            success: { appStoreLookup in
                guard let appId = appStoreLookup.results.first?.appID else { return }
                Storage.save(appId: appId)
        },
            failure: { [weak self] error in
                self?.stopAnimateActivity()
                self?.showErrorAlert(error)
        })
    }
    
}

private extension CoinsViewController {
    
    func stopAnimateActivity() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator?.stopAnimating()
            self?.collectionView.visibleCells.forEach {
                if let tableCell = $0 as? TickerListCollectionViewCell { tableCell.stopRefreshing() }
            }
        }
    }
}

