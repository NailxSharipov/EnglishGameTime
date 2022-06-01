//
//  SubscriptionView+ViewModel.swift
//  BigBanEng
//
//  Created by Nail Sharipov on 30.05.2022.
//

import SwiftUI
import StoreKit

extension SubscriptionView {
    
    final class ViewModel: ObservableObject {
        
        struct Alert {
            let message: String
            var isShow: Bool
        }
        
        var onSuccess: (() -> ())?
        var alert = Alert(message: "", isShow: false)
        private var selectedId: String = Product.SubscriptionId.yearly.rawValue
        private let trackingSystem: TrackingSystem
        private let subscriptionResource: SubscriptionResource
        
        init(subscriptionResource: SubscriptionResource, trackingSystem: TrackingSystem) {
            self.subscriptionResource = subscriptionResource
            self.trackingSystem = trackingSystem
        }
        
        private (set) var cells: [SubscriptionCell.ViewModel] = []

        func onTap(id: String) {
            guard selectedId != id else { return }
            selectedId = id
            withAnimation(.easeOut(duration: 0.4)) {
                for cell in cells {
                    if cell.id != id && cell.style != .simple {
                        cell.style = .simple
                        cell.objectWillChange.send()
                    } else if cell.id == id && cell.style != .selected {
                        cell.style = .selected
                        cell.objectWillChange.send()
                    }
                }
            }
        }
        
        func onLoad() async {
            trackingSystem.track(event: .subscription_open)
            do {
                let products = try await subscriptionResource.load()
                await self.update(products: products)
            } catch {
                await self.show(error: error.localizedDescription)
            }
        }
        
        @MainActor
        func show(error: String) {
            self.alert = Alert(message: error, isShow: true)
            self.objectWillChange.send()
        }
        
        @MainActor
        func update(products: [Product]) {
            let monthlyId = Product.SubscriptionId.monthly.rawValue
            let monthly = products.first(where: { $0.id == monthlyId })

            cells.removeAll()
            let month = "lze_month".locolize.uppercased()
            
            let monthPrice: Double?
            if let priceForMonth = monthly?.price {
                monthPrice = Double(truncating: priceForMonth as NSNumber)
            } else {
                monthPrice = nil
            }
            let locSale = "lze_sale".locolize
            
            for product in products {
                let safe: String
                let pricePerUnit: String
                if product.id != monthlyId, let monthPrice = monthPrice, let sale = product.compare(priceForMonth: monthPrice) {
                    safe = "\(locSale) \(sale.off)%"
                    pricePerUnit = "\(sale.pricePerUnit)/\(month)"
                } else {
                    safe = ""
                    pricePerUnit = "\(product.displayPrice)/\(month)"
                }
                
                let cell = SubscriptionCell.ViewModel(
                    product: product,
                    style: selectedId == product.id ? .selected : .simple,
                    isSale: !safe.isEmpty,
                    name: product.displayName,
                    price: product.displayPrice,
                    safe: safe,
                    pricePerUnit: pricePerUnit
                )
                
                cells.append(cell)
            }

            self.objectWillChange.send()
        }
        
        func subscribe() {
            guard let product = cells.first(where: { $0.product.id == selectedId })?.product else { return }
            
            Task { [weak self] in
                guard let self = self else { return }
                do {
                    let result = try await self.subscriptionResource.purchase(product: product)
                    await self.didSubcribe(result: result)
                } catch {
                    await self.show(error: error.localizedDescription)
                }
                
            }
        }
        
        @MainActor
        private func didSubcribe(result: Bool) async {
            if result {
                self.onSuccess?()
            }
        }
        
    }

}

private struct SalePrice {
    let off: Int
    let pricePerUnit: String
}

private extension Product {

    func compare(priceForMonth: Double) -> SalePrice? {
        guard let subscription = self.subscription, let months = subscription.subscriptionPeriod.months else { return nil }
                
        let m = Double(truncating: months as NSNumber)
        let p = Double(truncating: price as NSNumber)
        
        let total = m * priceForMonth
        let safe = total - p
        let off = (100 * safe / total).rounded(.toNearestOrAwayFromZero)
        
        let pricePerUnit = (price / months) as NSNumber
        let locPricePerUnit = NumberFormatter.localizedString(from: pricePerUnit, number: .currency)

        return SalePrice(off: Int(off), pricePerUnit: locPricePerUnit)
    }
}


extension Product.SubscriptionPeriod {
    
    var months: Decimal? {
        let scale: Decimal
        switch self.unit {
        case .day:
            scale = 1 / 30
        case .week:
            scale = 7 / 30
        case .month:
            scale = 1
        case .year:
            scale = 12
        @unknown default:
            return nil
        }
        
        return scale * Decimal(value)
    }
    
}
