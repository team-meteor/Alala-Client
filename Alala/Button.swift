//
//  Button.swift
//  Alala
//
//  Created by lee on 2017. 7. 1..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit

class Button: UIButton {
  override func draw(_ rect: CGRect) {
    let path = UIBezierPath(ovalIn: rect)
    UIColor.black.withAlphaComponent(0.5).setFill()
    path.fill()

    let lineHeight: CGFloat = 1.0
    let lineWidth: CGFloat = min(bounds.width, bounds.height)
    let linePath = UIBezierPath()

    let upperStartPointX = bounds.width / 2 + bounds.width / 4
    let upperStartPointY = bounds.height / 2 - bounds.height / 4

    linePath.lineWidth = lineHeight

    linePath.move(to: CGPoint(x: upperStartPointX, y: upperStartPointY))
    linePath.addLine(to: CGPoint(x: upperStartPointX - lineWidth/4, y: upperStartPointY))
    UIColor.white.setStroke()
    linePath.stroke()

    linePath.move(to: CGPoint(x: upperStartPointX, y: upperStartPointY))
    linePath.addLine(to: CGPoint(x: upperStartPointX, y: upperStartPointY + lineWidth/4))
    UIColor.white.setStroke()
    linePath.stroke()

    let lowerStartPointX = bounds.width / 2 - bounds.width / 4
    let lowerStartPointY = bounds.height / 2 + bounds.height / 4

    linePath.lineWidth = lineHeight

    linePath.move(to: CGPoint(x: lowerStartPointX, y: lowerStartPointY))
    linePath.addLine(to: CGPoint(x: lowerStartPointX + lineWidth/4, y: lowerStartPointY))
    UIColor.white.setStroke()
    linePath.stroke()

    linePath.move(to: CGPoint(x: lowerStartPointX, y: lowerStartPointY))
    linePath.addLine(to: CGPoint(x: lowerStartPointX, y: lowerStartPointY - lineWidth/4))
    UIColor.white.setStroke()
    linePath.stroke()

  }

}
