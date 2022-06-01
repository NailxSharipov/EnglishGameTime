//
//  SubscriptionCell.swift
//  BigBanEng
//
//  Created by Nail Sharipov on 30.05.2022.
//

import SwiftUI
import StoreKit

private extension Color {
    static let lightGray = Color(white: 0.9)
}

struct SubscriptionCell: View {
    
    final class ViewModel: Identifiable, ObservableObject {

        enum Style {
            case selected
            case simple
        }
        
        var id: String { product.id }
        var style: Style
        let isSale: Bool
        let product: Product
        let name: String
        let price: String
        let safe: String
        let pricePerUnit: String
        
        init(product: Product, style: Style, isSale: Bool, name: String, price: String, safe: String, pricePerUnit: String) {
            self.product = product
            self.style = style
            self.isSale = isSale
            self.name = name
            self.price = price
            self.safe = safe
            self.pricePerUnit = pricePerUnit
        }
        
    }
    
    let cellNameSpace: Namespace.ID
    
    @ObservedObject
    var viewModel: ViewModel
    
    var body: some View {
        GeometryReader { proxy in
            switch viewModel.style {
            case .simple:
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 1).foregroundColor(Color.lightGray)
                    if viewModel.isSale {
                        Text(viewModel.safe)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(4)
                            .background(Color.lightGray)
                            .cornerRadius(4)
                    }
                    ZStack(alignment: .center) {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(viewModel.name).font(.system(size: 16, weight: .regular)).foregroundColor(.gray)
                                Text(viewModel.price).font(.system(size: 12, weight: .regular)).foregroundColor(.gray)
                            }.padding(.leading, 20)
                            Spacer()
                            Text(viewModel.pricePerUnit).font(.system(size: 14, weight: .regular)).foregroundColor(.gray).padding(.trailing, 8)
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                }.padding([.leading, .trailing], 6)
            case .selected:
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 4)
                        .foregroundColor(.yellow)
                        .zIndex(1)
                        .matchedGeometryEffect(id: "rect", in: cellNameSpace)
                    if viewModel.isSale {
                        Text(viewModel.safe)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(4)
                            .background(.yellow)
                            .cornerRadius(4)
                    }
                    ZStack(alignment: .center) {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(viewModel.name).font(.system(size: 16, weight: .semibold)).foregroundColor(.black)
                                Text(viewModel.price).font(.system(size: 12, weight: .semibold)).foregroundColor(.black)
                            }.padding(.leading, 20)
                            Spacer()
                            Text(viewModel.pricePerUnit).font(.system(size: 14, weight: .semibold)).foregroundColor(.black).padding(.trailing, 8)
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    ZStack {
                        Check(color: .yellow).frame(width: 24, height: 24).padding(6)
                            .matchedGeometryEffect(id: "check", in: cellNameSpace)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
            }
        }.background(Color(white: 1, opacity: 0.1))
    }

}


private struct Check: View {
    
    let color: Color
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Path { path in
                    path.addEllipse(in: CGRect(origin: .zero, size: proxy.size))
                    path.closeSubpath()
                }.fill(color)
                Path { path in
                    let w = proxy.size.width
                    let h = proxy.size.height
                    
                    let p1 = CGPoint(x: 0.45 * w, y: 0.73 * h)
                    let p0 = p1 + CGPoint(x: -1/4 * w, y: -1/4 * h)
                    let p2 = p1 + CGPoint(x: 3/8 * w, y: -3/8 * h)
                    
                    path.move(to: p0)
                    path.addLine(to: p1)
                    path.addLine(to: p2)
                }
                .strokedPath(.init(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .foregroundColor(.white)
            }
        }
    }
}
