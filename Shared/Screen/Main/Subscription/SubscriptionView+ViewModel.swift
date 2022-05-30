//
//  SubscriptionView+ViewModel.swift
//  BigBanEng
//
//  Created by Nail Sharipov on 30.05.2022.
//

import SwiftUI

extension SubscriptionView {
    
    final class ViewModel: ObservableObject {
        
        private (set) var cells: [SubscriptionCell.ViewModel] = [
            .init(id: 0, style: .simple, time: "12 месяцев", price: "4750 р", pricePerTime: "390 р/месяц"),
            .init(id: 1, style: .selected, time: "6 месяцев", price: "3250 р", pricePerTime: "540 р/месяц")
        ]

        
        func onTap(id: Int) {
            for cell in cells {
                if cell.id != id && cell.style != .simple {
                    withAnimation(.linear(duration: 0.2)) {
                        cell.style = .simple
                        cell.objectWillChange.send()
                    }
                } else if cell.id == id && cell.style != .selected {
                    withAnimation(.linear(duration: 0.2)) {
                        cell.style = .selected
                        cell.objectWillChange.send()
                    }
                }
            }
        }
        
    }

}
