//
//  TickerListCollectionViewCell.swift
//  Coins
//
//  Created by Artem Kirillov on 11.08.2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

protocol TickerListCollectionViewCellDelegate: class {
    func tickerListCollectionViewCellDidRequestUpdate(cell: TickerListCollectionViewCell)
    func tickerListCollectionViewCell(cell: TickerListCollectionViewCell, didSelectRowAt index: Int, frame: CGRect)
}

class TickerListCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    
    weak var delegate: TickerListCollectionViewCellDelegate?
    
    // MARK: - Constructors
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 110.0
        
        tableView.register(UINib(nibName: "TickerCell", bundle: nil), forCellReuseIdentifier: "TickerTableViewCell")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds
    }
    
    func configure(items: [Ticker], noItemsText: String) {
        self.items = items
        
        if items.isEmpty {
            let noItemsLabel = UILabel()
            noItemsLabel.text = noItemsText
            noItemsLabel.numberOfLines = 0
            noItemsLabel.textColor = .lightGray
            noItemsLabel.textAlignment = .center
            tableView.backgroundView = noItemsLabel
        } else {
            tableView.backgroundView = nil
        }
        
        tableView.reloadData()
        stopRefreshing()
    }
    
    @objc func updateData() {
        delegate?.tickerListCollectionViewCellDidRequestUpdate(cell: self)
    }
    
    func stopRefreshing() {
        tableView.refreshControl?.endRefreshing()
    }
    
    // MARK: - Private Properties
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var items: [Ticker] = []
    
}

// MARK: - UITableViewDataSource

extension TickerListCollectionViewCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TickerTableViewCell", for: indexPath) as! TickerTableViewCell
        cell.configure(ticker: items[indexPath.row])
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension TickerListCollectionViewCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        var frame = tableView.cellForRow(at: indexPath)?.frame ?? .zero
        let newOrigin = convert(frame.origin, from: tableView)
        frame.origin = newOrigin
        
        delegate?.tickerListCollectionViewCell(cell: self, didSelectRowAt: indexPath.row, frame: frame)
    }
    
}

