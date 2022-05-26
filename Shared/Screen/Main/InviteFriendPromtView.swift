//
//  InviteFriendPromtView.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 26.05.2022.
//

import SwiftUI

struct InviteFriendPromtView: View {


    let color: Color
    let onClose: () -> ()
    
    @State
    private var radius: CGFloat = 1
    @State
    private var isClosed: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .center) {
                CornerInverseFill(radius: radius).fill(color)
                CornerFill(radius: radius).fill(.white)
                Text("Share with your friends to get more free levels")
                    .font(.system(size: 32, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(proxy.isIPad ? 100 : 50).multilineTextAlignment(.center)
                    .opacity(1 - radius)
            }
        }
        .onAppear() {
            withAnimation(.linear(duration: 1)) {
                radius = 0
            }
        }.gesture(TapGesture().onEnded() {
            guard !isClosed else { return }
            isClosed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                onClose()
            }
            withAnimation(.linear(duration: 1)) {
                radius = 1
            }
        })
    }
}

private struct CornerInverseFill: Shape, Animatable {

    var animatableData: CGFloat {
        get {
            radius
        }
        set {
            radius = newValue
        }
    }

    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        
        let w = rect.width
        let h = rect.height

        let m = (rect.width * rect.width + rect.height * rect.height).squareRoot()
        let r = m * radius
        
        let center = CGPoint(x: w, y: h)

        return Path() { path in
//            path.move(to: CGPoint(x: w - r, y: h))
            path.addArc(center: center, radius: r, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 90), clockwise: false)
            path.addLine(to: CGPoint(x: w, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: h))
            path.closeSubpath()
        }
    }
}

private struct CornerFill: Shape, Animatable {

    var animatableData: CGFloat {
        get {
            radius
        }
        set {
            radius = newValue
        }
    }
    
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        
        let w = rect.width
        let h = rect.height
        
        let m: CGFloat = 200
        let r = m * (1 - radius)

        let center = CGPoint(x: w, y: h)

        return Path() { path in
            path.addArc(center: center, radius: r, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 90), clockwise: false)
            path.addLine(to: CGPoint(x: w, y: h))
            path.closeSubpath()
        }
    }
}
