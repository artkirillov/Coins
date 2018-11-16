//
//  StoreManager.swift
//  Coins
//
//  Created by Artem Kirillov on 01.09.2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import StoreKit

class StoreManager: NSObject {
    
    // MARK: - Public Properties
    
    var unlimitedPortfolioProduct: SKProduct?
    
    // MARK: - Constructors
    
    override init() {
        super.init()
        
        let productRequest = SKProductsRequest(productIdentifiers: [unlimitedPortfolioProductIdentifier])
        productRequest.delegate = self
        productRequest.start()
    }
    
    // MARK: - Public Methods
    
    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func makePayment(with product: SKProduct) {
        SKPaymentQueue.default().add(SKPayment(product: product))
    }
    
    // MARK: - Private Properties
    
    private let unlimitedPortfolioProductIdentifier = "unlimitedPortfolio"
    
}

// MARK: - SKProductsRequestDelegate

extension StoreManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        unlimitedPortfolioProduct = response.products.first(where: { $0.productIdentifier == unlimitedPortfolioProductIdentifier })
        assert(response.invalidProductIdentifiers.isEmpty)
    }
}

// MARK: - SKPaymentTransactionObserver

extension StoreManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .deferred, .failed, .purchasing: break
            case .purchased, .restored:
                Storage.save(maxPortfolioVolume: Int.max)
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
}
