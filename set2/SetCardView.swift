//
//  SetCardView.swift
//  set2
//
//  Created by Anthony Mackay on 2/2/19.
//  Copyright © 2019 Anthony Mackay. All rights reserved.
//

import UIKit

@IBDesignable
class SetCardView: UIView {
    @IBInspectable
    private var shape: Shape = Shape.triangle {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable
    private var number: Number = Number.two {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable
    private var shading: Shading = Shading.semitransparent {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable
    private var color: Color = Color.blue {
        didSet { setNeedsDisplay() }
    }
    
    override func draw(_ rect: CGRect) {
        let cardSize = getCardBounds(fromBounds: self.bounds)
        let cardPath = UIBezierPath(roundedRect: cardSize, cornerRadius: cardSize.width * Constants.cornerRadiusRatio)
        
        let symbolsAreaBounds = cardSize.insetBy(dx: Constants.cardSymbolAreaInset * cardSize.width, dy: Constants.cardSymbolAreaInset * cardSize.height)
        let symbolBounds = SymbolBounds.splitIntoSymbolBounds(symbolsAreaBounds)
        UIColor.white.setFill()
        cardPath.fill()
        
        switch number {
        case .one:
            drawSymbol(withShape: shape, andShading: shading, andColor: color, withinBounds: symbolBounds.middle)
        case .two:
            drawSymbol(withShape: shape, andShading: shading, andColor: color, withinBounds: symbolBounds.top)
            drawSymbol(withShape: shape, andShading: shading, andColor: color, withinBounds: symbolBounds.middle)
        case .three:
            drawSymbol(withShape: shape, andShading: shading, andColor: color, withinBounds: symbolBounds.top)
            drawSymbol(withShape: shape, andShading: shading, andColor: color, withinBounds: symbolBounds.middle)
            drawSymbol(withShape: shape, andShading: shading, andColor: color, withinBounds: symbolBounds.bottom)
        }
    }
    
    private func getCardBounds(fromBounds bounds: CGRect) -> CGRect {
        let boundsRatio = bounds.width / bounds.height
        if boundsRatio > Constants.cardRatio {
            let desiredWidth = bounds.height * Constants.cardRatio
            let widthDifference = abs(bounds.width - desiredWidth)
            // The bounds are wider than the desired aspect ratio, so we shrink the width:
            return CGRect(x: bounds.minX + widthDifference / 2, y: bounds.minY, width: bounds.width - widthDifference, height: bounds.height)
        } else if boundsRatio < Constants.cardRatio {
            // The bounds are thinner than the desired aspect ration, so we shrink the height:
            let desiredHeight = bounds.width / Constants.cardRatio
            let heightDifference = abs(bounds.height - desiredHeight)
            return CGRect(x: bounds.minX, y: bounds.minY + heightDifference / 2, width: bounds.width, height: bounds.height - heightDifference)
        } else {
            return bounds
        }
    }

    
    private func getPath(forShape shape: Shape, withinBounds squareBounds: CGRect) -> UIBezierPath {
        switch shape {
        case .circle:
            return UIBezierPath(arcCenter: CGPoint(x: squareBounds.midX, y: squareBounds.midY), radius: squareBounds.width / 2, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        case .triangle:
            let path = UIBezierPath()
            path.move(to: CGPoint(x: squareBounds.midX, y: squareBounds.minY + Constants.equilateralTriangleHeightOffset * squareBounds.height))
            path.addLine(to: CGPoint(x: squareBounds.maxX, y: squareBounds.maxY - Constants.equilateralTriangleHeightOffset * squareBounds.height))
            path.addLine(to: CGPoint(x: squareBounds.minX, y: squareBounds.maxY - Constants.equilateralTriangleHeightOffset * squareBounds.height))
            path.close()
            return path
        case .square:
            return UIBezierPath(rect: squareBounds)
        }
    }
    
    private func drawSymbol(withShape shape: Shape, andShading shading: Shading, andColor color: Color, withinBounds b: CGRect) {
        let insetBounds = b.insetBy(dx: Constants.symbolInset * b.width, dy: Constants.symbolInset * b.height)
        var squareInsetBounds: CGRect? = nil
        if insetBounds.width >= insetBounds.height {
            let newWidth = insetBounds.height
            let widthDifference = abs(newWidth - insetBounds.width)
            let widthInset = widthDifference / 2
            squareInsetBounds = insetBounds.insetBy(dx: widthInset, dy: 0)
        } else {
            let newHeight = insetBounds.width
            let heightDifference = abs(newHeight - insetBounds.height)
            let heightInset = heightDifference / 2
            squareInsetBounds = insetBounds.insetBy(dx: 0, dy: heightInset)
        }
        let path = getPath(forShape: shape, withinBounds: squareInsetBounds!)
        path.lineWidth = Constants.strokeWidth * squareInsetBounds!.width
        let uiColor = color.toColor()
        uiColor.setStroke()
        
        switch shading {
        case .outline: break
        case .filled:
            uiColor.setFill()
            path.fill()
        case .semitransparent:
            uiColor.withAlphaComponent(Constants.alphaComponent).setFill()
            path.fill()
        }
        
        path.stroke()
    }
    
    private struct SymbolBounds {
        let top: CGRect
        let middle: CGRect
        let bottom: CGRect
        
        static func splitIntoSymbolBounds(_ symbolAreaBounds: CGRect) -> SymbolBounds {
            let width = symbolAreaBounds.width
            let height = symbolAreaBounds.height
            let minX = symbolAreaBounds.minX
            let minY = symbolAreaBounds.minY
            let newHeight = height / 3
            
            let top = CGRect(x: minX, y: minY, width: width, height: newHeight)
            let middle = CGRect(x: minX, y: minY + newHeight, width: width, height: newHeight)
            let bottom = CGRect(x: minX, y: minY + 2 * newHeight, width: width, height: newHeight)
            return SymbolBounds(top: top, middle: middle, bottom: bottom)
        }
    }
    
    @objc
    private enum Shape: Int {
        case circle
        case triangle
        case square
    }
    
    @objc
    private enum Number: Int {
        case one = 1
        case two = 2
        case three = 3
    }
    
    @objc
    private enum Shading: Int {
        case outline
        case filled
        case semitransparent
    }
    
    @objc
    private enum Color: Int {
        case orange
        case green
        case blue
        
        func toColor() -> UIColor {
            switch self {
            case .orange: return #colorLiteral(red: 0.9872463346, green: 0.6835058331, blue: 0.2003244758, alpha: 1)
            case .green: return #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
            case .blue: return #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            }
        }
    }
    
    
}

fileprivate struct Constants {
    static let symbolInset: CGFloat = 0.1
    static let alphaComponent: CGFloat = 0.45
    static let strokeWidth: CGFloat = 0.05
    static let equilateralTriangleHeightOffset: CGFloat = 0.06
    
    static let cardRatio: CGFloat = 0.66 // card width to height
    static let cornerRadiusRatio: CGFloat = 0.18 // card width to corner radius
    static let cardSymbolAreaInset: CGFloat = 0.1
}
