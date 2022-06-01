//
//  SubscriptionResource.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 18.05.2022.
//

import Foundation
import StoreKit

//https://developer.apple.com/documentation/storekit/transaction/3851206-updates
actor SubscriptionResource {
    
    private struct Subscription {
        weak var observer: AnyObject?
        let onReceive: (Bool) -> ()
        
        init(observer: AnyObject, callback: @escaping (Bool) -> ()) {
            self.observer = observer
            self.onReceive = callback
        }
    }

    static let shared = SubscriptionResource()
    
    private var updates: Task<Void, Never>? = nil
    private let trackingSystem: TrackingSystem = GoogleAnalytics.shared
    private var subscriptions: [Subscription] = []
    private var isActive: Bool?
    
    func load() async throws -> [Product] {
        let products = try await Product.products(for: Product.all)
            .filter({ $0.type == .autoRenewable })
            .sorted(by: { $0.price < $1.price })
        return products
    }
    
    func purchase(product: Product) async throws -> Bool {
        trackingSystem.track(event: .subscription_try)
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            guard let transaction = checkVerified(verification) else {
                return false
            }
            
            let isValid = transaction.revocationDate == nil
            if isValid {
                self.trackingSystem.track(event: .subscription_success)
            }
            
            await transaction.finish()
            await self.update()
            return true
        case .pending:
            return false
        case .userCancelled:
            trackingSystem.track(event: .subscription_user_cancel)
            return false
        @unknown default:
            trackingSystem.track(event: .subscription_system_fail)
            return false
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) -> T? {
        switch result {
        case .unverified:
            return nil
        case .verified(let safe):
            return safe
        }
    }

    func isSubscribed() async -> Bool {
        for id in Product.all {
            guard
                let verification = await Transaction.latest(for: id),
                let transaction = try? checkVerified(verification)
            else { continue }

            let isValid = transaction.revocationDate == nil
            
            if isValid {
                isActive = true
                return true
            }
        }
       
        isActive = false
        return false
    }
    
    private func newTransactionListenerTask() -> Task<Void, Never> {
        Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                await self.handle(updatedTransaction: verificationResult)
            }
        }
    }
    
    private func handle(updatedTransaction verificationResult: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = verificationResult else {
            // Ignore unverified transactions.
            return
        }

        let isValid = transaction.revocationDate == nil
        if isValid {
            self.trackingSystem.track(event: .subscription_success)
        }

        await transaction.finish()

        await self.update()
    }
    
    private func update() async {
        let isActive = self.isActive
        
        let newActive = await self.isSubscribed()
        if newActive != isActive {
            await self.notify(status: newActive)
        }
    }
    

    func subscribe(_ observer: AnyObject, callback: @escaping (Bool) -> ()) async {
        subscriptions.append(Subscription(observer: observer, callback: callback))
        if updates == nil {
            updates = self.newTransactionListenerTask()
        }
    }

    @MainActor
    private func notify(status: Bool) async {
        let list = await subscriptions.filter({ $0.observer != nil })
        for subscription in list {
            subscription.onReceive(status)
        }
    }
}
