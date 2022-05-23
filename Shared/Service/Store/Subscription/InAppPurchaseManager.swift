//
//  InAppPurchaseManager.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 19.05.2022.
//

import StoreKit

typealias ProductID = String
typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void
typealias ProductPurchaseCompletionHandler = (_ success: Bool, _ productId: ProductID?) -> Void

final class InAppPurchaseManager: NSObject  {
    
    private let productIDs: Set<ProductID>
    private var purchasedProductIDs: Set<ProductID>
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    private var productPurchaseCompletionHandler: ProductPurchaseCompletionHandler?
  
    init(productIDs: Set<ProductID>) {
        self.productIDs = productIDs
        self.purchasedProductIDs = productIDs.filter { productID in
            let purchased = UserDefaults.standard.bool(forKey: productID)
            if purchased {
                debugPrint("Previously purchased: \(productID)")
            } else {
                debugPrint("Not purchased: \(productID)")
            }
            return purchased
        }
        super.init()
        SKPaymentQueue.default().add(self)
    }
}

extension InAppPurchaseManager {
    
    func requestProducts(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        
        productsRequest = SKProductsRequest(productIdentifiers: productIDs)
        productsRequest!.delegate = self
        productsRequest!.start()
    }

    func buyProduct(_ product: SKProduct, _ completionHandler: @escaping ProductPurchaseCompletionHandler) {
        productPurchaseCompletionHandler = completionHandler
        debugPrint("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    func isProductPurchased(_ productID: ProductID) -> Bool {
        purchasedProductIDs.contains(productID)
    }
  
    static func canMakePayments() -> Bool {
        SKPaymentQueue.canMakePayments()
    }
  
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}

extension InAppPurchaseManager: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        debugPrint("Loaded list of products...")
        let products = response.products
        guard !products.isEmpty else {
            debugPrint("Product list is empty...!")
            debugPrint("Did you configure the project and set up the IAP?")
            productsRequestCompletionHandler?(false, nil)
            return
        }
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
        for p in products {
            debugPrint("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        debugPrint("Failed to load list of products.")
        debugPrint("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }

    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

extension InAppPurchaseManager: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                debugPrint("purchased")
                complete(transaction: transaction)
                break
            case .failed:
                debugPrint("failed")
                fail(transaction: transaction)
                break
            case .restored:
                debugPrint("restored")
                restore(transaction: transaction)
                break
            case .deferred:
                debugPrint("deferred")
                break
            case .purchasing:
                debugPrint("purchasing")
                break
            @unknown default:
                debugPrint("Not implemented case")
            }
        }
    }

    private func complete(transaction: SKPaymentTransaction) {
        debugPrint("complete...")
        productPurchaseCompleted(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        debugPrint("restore... \(productIdentifier)")
        productPurchaseCompleted(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func fail(transaction: SKPaymentTransaction) {
        debugPrint("fail...")
        if let transactionError = transaction.error as NSError?,
           let localizedDescription = transaction.error?.localizedDescription,
           transactionError.code != SKError.paymentCancelled.rawValue {
            debugPrint("Transaction Error: \(localizedDescription)")
        }

        productPurchaseCompletionHandler?(false, nil)
        SKPaymentQueue.default().finishTransaction(transaction)
        clearHandler()
    }

    private func productPurchaseCompleted(identifier: ProductID?) {
        guard let identifier = identifier else { return }
        purchasedProductIDs.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        productPurchaseCompletionHandler?(true, identifier)
        clearHandler()
    }
    
    private func clearHandler() {
        productPurchaseCompletionHandler = nil
    }
}
