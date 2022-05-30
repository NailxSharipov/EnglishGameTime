//
//  SubscriptionCell.swift
//  BigBanEng
//
//  Created by Nail Sharipov on 30.05.2022.
//

import SwiftUI

struct SubscriptionCell: View {
    
    final class ViewModel: Identifiable, ObservableObject {

        enum Style {
            case selected
            case simple
        }
        
        let id: Int
        var style: Style
        let time: String
        let price: String
        let pricePerTime: String
        
        init(id: Int, style: Style, time: String, price: String, pricePerTime: String) {
            self.id = id
            self.style = style
            self.time = time
            self.price = price
            self.pricePerTime = pricePerTime
        }
        
    }
    
    @Namespace
    private var cellNameSpace
    
    @ObservedObject
    var viewModel: ViewModel
    
    var body: some View {
        GeometryReader { proxy in
            switch viewModel.style {
            case .simple:
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 1).foregroundColor(.gray)
                        .matchedGeometryEffect(id: "\(viewModel.id)_rect", in: cellNameSpace)
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(viewModel.time).font(.system(size: 16, weight: .regular)).foregroundColor(.gray)
                            Text(viewModel.price).font(.system(size: 12, weight: .regular)).foregroundColor(.gray)
                        }.padding(.leading, 20)
                        Spacer()
                        Text(viewModel.pricePerTime).font(.system(size: 14, weight: .regular)).foregroundColor(.gray).padding(.trailing, 20)
                    }
                }.padding(8).background(.white)
            case .selected:
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 4).foregroundColor(.yellow)
                        .matchedGeometryEffect(id: "\(viewModel.id)_rect", in: cellNameSpace)
                    Text("Popular")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(4)
                        .background(.yellow)
                    ZStack(alignment: .center) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(viewModel.time).font(.system(size: 16, weight: .semibold)).foregroundColor(.gray)
                                Text(viewModel.price).font(.system(size: 12, weight: .semibold)).foregroundColor(.gray)
                            }.padding(.leading, 20)
                            Spacer()
                            Text(viewModel.pricePerTime).font(.system(size: 14, weight: .semibold)).foregroundColor(.gray).padding(.trailing, 20)
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                }.cornerRadius(8).background(.white)
            }
        }
    }

}
