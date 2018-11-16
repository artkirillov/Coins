//
//  CoinsCatalogViewController.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 03.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

protocol CoinsCatalogViewControllerDelegate: class {
    func coinsCatalogViewController(controller: CoinsCatalogViewController, didSelect coin: Coin)
}

final class CoinsCatalogViewController: UIViewController {
    
    // MARK: - Public Properties
    
    weak var delegate: CoinsCatalogViewControllerDelegate?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let coins = Storage.coins() ?? []
        items = coins.sorted(by: { $0.symbol < $1.symbol })
        filteredItems = items
        
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
        
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40.0
    }
    
    @objc func clearSearchTextField() {
        searchTextField.text = nil
        searchTextFieldClearButton?.isHidden = true
        filteredItems = items
        view.endEditing(true)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private var tableView: UITableView!
    private var searchTextFieldClearButton: UIButton?
    
    private var items: [Coin] = []
    private var filteredItems: [Coin] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
}

// MARK: - UITableViewDataSource

extension CoinsCatalogViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoinItemCell", for: indexPath) as! CoinItemTableViewCell
        cell.configure(coin: filteredItems[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDataSource

extension CoinsCatalogViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)
        delegate?.coinsCatalogViewController(controller: self, didSelect: filteredItems[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UITextFieldDelegate

extension CoinsCatalogViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text else {
            self.filteredItems = self.items
            return true
        }
        
        updateItems(withSearchText: string.isEmpty ? String(textFieldText.dropLast()) : textFieldText + string)
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
    
    private func updateItems(withSearchText searchText: String) {
        let filteredItems = items.filter { $0.name.lowercased().range(of: searchText.lowercased()) != nil || $0.symbol.lowercased().range(of: searchText.lowercased()) != nil }
        
        if filteredItems.isEmpty {
            let noItemsLabel = UILabel()
            noItemsLabel.text = NSLocalizedString("Can't find any coins", comment: "")
            noItemsLabel.numberOfLines = 0
            noItemsLabel.textColor = .lightGray
            noItemsLabel.textAlignment = .center
            tableView.backgroundView = noItemsLabel
        } else {
            tableView.backgroundView = nil
        }
        self.filteredItems = filteredItems
    }
    
}
