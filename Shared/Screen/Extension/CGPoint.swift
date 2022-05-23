//
//  CGPoint.swift
//  EnglishGameTime
//
//  Created by Nail Sharipov on 23.05.2022.
//

import CoreGraphics

@inline(__always)
func +(left: CGPoint, right: CGPoint) -> CGPoint {
    CGPoint(x: left.x + right.x, y: left.y + right.y)
}

@inline(__always)
func *(left: CGFloat, right: CGPoint) -> CGPoint {
    CGPoint(x: left * right.x, y: left * right.y)
}
