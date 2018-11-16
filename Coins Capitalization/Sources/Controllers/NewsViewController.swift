//
//  NewsViewController.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 20.06.2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit
import SafariServices

final class NewsViewController: UIViewController {
    
    // MARK: - Public Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 135.5
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        if let activityIndicatorView = activityIndicator { view.addSubview(activityIndicatorView) }
        activityIndicator?.center = view.center
        activityIndicator?.startAnimating()
        
        requestData()
    }
    
    @objc func updateData() {
        requestData()
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private var tableView: UITableView!
    private var activityIndicator: UIActivityIndicatorView?
    private var items: [Article] = []
    private var itemsNeedReset: Bool = false
    private var requestedAt: Date = Date()
    
}

// MARK: - UITableViewDataSource

extension NewsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleTableViewCell
        cell.configure(article: items[indexPath.row])
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension NewsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "ArticleViewController") as? ArticleViewController
        else { return }
        
        controller.urlString = items[indexPath.row].url
        controller.host = items[indexPath.row].source.name
        
        present(controller, animated: true, completion: nil)
    }
}

// MARK: - Network Requests

private extension NewsViewController {
    
    func requestData() {
        
        guard items.isEmpty || DateInterval(start: requestedAt, end: Date()).duration > TimeInterval(floatLiteral: 60)
        else {
            stopAnimateActivity()
            return
        }
        
        guard Reachability.isConnectedToNetwork() else {
            stopAnimateActivity()
            showErrorAlert(title: NSLocalizedString("Something has gone wrong", comment: ""),
                           message: NSLocalizedString("The Internet connection appears to be offline", comment: ""))
            return
        }
        
        itemsNeedReset = true
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            for feed in RSS.feeds {
                let rss = RSS()
                rss.requestNewsArticles(from: feed,
                                        success: { articles in
                                            DispatchQueue.main.async { [weak self] in
                                                guard let slf = self else { return }

                                                if slf.itemsNeedReset {
                                                    slf.items = []
                                                    slf.requestedAt = Date()
                                                }
                                                
                                                slf.itemsNeedReset = false
                                                
                                                slf.items = (slf.items + articles)
                                                    .sorted { ($0.publishedAt ?? Date()) > ($1.publishedAt ?? Date()) }
                                                slf.tableView.reloadData()
                                                slf.stopAnimateActivity()
                                            }
                },
                                        failure: { [weak self] error in
                                            self?.stopAnimateActivity()
                                            self?.showErrorAlert(error)
                })
            }
        }
    }
}

private extension NewsViewController {
    
    func stopAnimateActivity() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.refreshControl?.endRefreshing()
            self?.activityIndicator?.stopAnimating()
        }
    }
}
