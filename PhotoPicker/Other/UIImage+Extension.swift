//
//  UIImage+Extension.swift
//  PhotoPicker
//
//  Created by 马磊 on 2019/1/21.
//  Copyright © 2019 MLCode. All rights reserved.
//

import Foundation

class PhotoPickerImage {
    
    
    class func getDigitImage(num: Int, fontSize: CGFloat = 6) -> UIImage? {
        var W: CGFloat = 25
        var H: CGFloat = 25
        let B: CGFloat = UIScreen.main.scale
        let P: PhotoIndicatorPosition = PhotoPickerManager.shared.options.indicatorPosition
        let style: PhotoIndicatorStyle = PhotoPickerManager.shared.options.indicatorStyle
        
        let str: NSString = String(num) as NSString
        
        var reduceFontSize = fontSize
        reduceFontSize -= num > 9 ? 1.5 : 0
        reduceFontSize -= num > 19 ? 1.5 : 0
        reduceFontSize -= style == .triangleFill ? 2 : 0
        reduceFontSize -= style == .triangleHalfFill ? 2 : 0
        reduceFontSize *= UIScreen.main.scale
        let font: UIFont = UIFont.systemFont(ofSize: reduceFontSize)
        
        let attrs: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font:font, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let viewSize = CGSize(width: ScreenW, height: CGFloat(MAXFLOAT))
        let size = str.boundingRect(with: viewSize, options: [.usesLineFragmentOrigin], attributes:attrs,context: nil)
        
        let X = B/2 + (W - B - size.width)/2
        let Y = B/2 + (H - B - size.height)/2
        
        var addX: CGFloat = 0
        var addY: CGFloat = 0
        
        switch style {
        case .circular,.star,.heart:
            return UIImage.size(width: W, height: H)
                .corner(radius: W * 0.5)
                .color(PhotoPickerManager.shared.options.tintColor)
                .border(color: .clear)
                .border(width: B)
                .image
                .with({ context in
                    str.draw(in: CGRect(x: X, y: Y, width: W, height: H), withAttributes:attrs)
                })
        case .square:
            return UIImage.size(width: W, height: H)
                .corner(topLeft: P == .bottomRight ? 0 : 0,
                        topRight: P == .bottomLeft ? 0 : 0,
                        bottomLeft: P == .topRight ? 0 : 0,
                        bottomRight: P == .topLeft ? 0 : 0)
                .color(PhotoPickerManager.shared.options.tintColor)
                .image
                .with({ context in
                    str.draw(in: CGRect(x: X + addX, y: Y + addY, width: W, height: H), withAttributes:attrs)
                })
        case .rectangle:
            // (self.checkboxPosition == .topRight || self.checkboxPosition == .bottomRight)
            addX = (P == .topRight || P == .bottomRight) ? (W * 2 + B * 0.5) : (-B * 0.5)
            addY = -B * 0.5
            W = W * 3
            H = H - B
            var fromPoint: CGPoint?
            var toPoint:CGPoint?
            switch P {
            case .topLeft:
                fromPoint = CGPoint(x: 0, y: 0)
                toPoint = CGPoint(x: 1, y: 1)
            case .topRight:
                fromPoint = CGPoint(x: 1, y: 0)
                toPoint = CGPoint(x: 0, y: 1)
            case .bottomLeft:
                fromPoint = CGPoint(x: 0, y: 1)
                toPoint = CGPoint(x: 1, y: 0)
            case .bottomRight:
                fromPoint = CGPoint(x: 1, y: 1)
                toPoint = CGPoint(x: 0, y: 0)
            }
            
            return UIImage.size(width: W, height: H)
                .corner(topLeft: P == .bottomRight ? 0 : 0,
                        topRight: P == .bottomLeft ? 0 : 0,
                        bottomLeft: P == .topRight ? 0 : 0,
                        bottomRight: P == .topLeft ? 0 : 0)
                .color(gradient: [
                    PhotoPickerManager.shared.options.tintColor.withAlphaComponent(1),
                    UIColor.white.withAlphaComponent(0.01)
                    ], locations: [0, 1], from: fromPoint!, to: toPoint!)
                .image
                .with({ context in
                    str.draw(in: CGRect(x: X + addX, y: Y + addY, width: W, height: H), withAttributes:attrs)
                })
        case .triangleFill, .triangleHalfFill:
            let beltLineW = W * 0.75
            let smallToBigSecondAddY: CGFloat = num > 19 ? 1 : (num > 9 ? 0.75 : 0.25)
            var beltMoveTo: CGPoint?
            var beltLineTo: CGPoint?
            var positionX: CGFloat = 0
            var positionY: CGFloat = 0
            switch PhotoPickerManager.shared.options.indicatorPosition {
            case .topLeft:
                addX = -W / 5
                addY = -(W / 5 + smallToBigSecondAddY)
                positionX = -0.000001
                positionY = 0
                beltMoveTo = CGPoint(x: W * 0.5, y: 0)
                beltLineTo = CGPoint(x: 0, y: H * 0.5)
            case .topRight:
                addX = W / 5
                addY = -(W / 5 + smallToBigSecondAddY)
                positionX = W * 0.5
                positionY = 0
                beltMoveTo = CGPoint(x: W * 0.5, y: 0)
                beltLineTo = CGPoint(x: W, y: H * 0.5)
            case .bottomLeft:
                addX = -W / 5
                addY = W / 5  + smallToBigSecondAddY
                positionX = 0
                positionY = W * 0.5
                beltMoveTo = CGPoint(x: -W * 0.25, y: H * 0.25)
                beltLineTo = CGPoint(x: W * 0.5, y: H)
            case .bottomRight:
                addX = W / 5
                addY = W / 5 + smallToBigSecondAddY
                positionX = W * 0.5
                positionY = W * 0.5
                beltMoveTo = CGPoint(x: W, y: H * 0.5)
                beltLineTo = CGPoint(x: W * 0.5, y: H)
            }
            
            let image = UIImage.size(width: W, height: H)
                .color(.clear)
                .image
                .with({ context in
                    context.setLineCap(.square)
                    PhotoPickerManager.shared.options.tintColor.setStroke()
                    context.setLineWidth(beltLineW)
                    context.move(to: beltMoveTo!)
                    context.addLine(to: beltLineTo!)
                    context.strokePath()
                    
                    str.draw(in: CGRect(x: X + addX, y: Y + addY, width: W, height: H), withAttributes:attrs)
                })
            return style == .triangleFill ? image : UIImage.size(width: W * 1.5, height: H * 1.5).color(.clear).image + image.position(CGPoint(x: positionX, y: positionY))
        }
    }
    
    public class func getImage(isRemove: Bool = false,
                                 style: PhotoIndicatorStyle = PhotoPickerManager.shared.options.indicatorStyle,
                                 useUserSize: CGFloat = 0
        ) -> (select:UIImage,unselect:UIImage,size:CGSize) {
        
        var W: CGFloat = 25
        var H: CGFloat = 25
        let L: CGFloat = 1.5
        let B: CGFloat = UIScreen.main.scale
        
        let M = W * 0.111111
    
        let P: PhotoIndicatorPosition = PhotoPickerManager.shared.options.indicatorPosition
        
        var shape: [CGFloat] = [3,5,4,6,4,6,6,3]
        
        let tin = PhotoPickerManager.shared.options.tintColor
        
        var imageSelect:UIImage?
        var imageUnselect:UIImage?
        
        var fromPoint: CGPoint?
        var toPoint:CGPoint?
        switch P {
        case .topLeft:
            fromPoint = CGPoint(x: 0, y: 0)
            toPoint = CGPoint(x: 1, y: 1)
        case .topRight:
            fromPoint = CGPoint(x: 1, y: 0)
            toPoint = CGPoint(x: 0, y: 1)
        case .bottomLeft:
            fromPoint = CGPoint(x: 0, y: 1)
            toPoint = CGPoint(x: 1, y: 0)
        case .bottomRight:
            fromPoint = CGPoint(x: 1, y: 1)
            toPoint = CGPoint(x: 0, y: 0)
        }
        
        var addX: CGFloat = 0
        var addY: CGFloat = 0
        
        switch style {
        case .circular:
            let spaceW = min(W/10,L*2)
            imageUnselect = (UIImage.size(width: W, height: H)
                .corner(radius: W * 0.5)
                .border(color: .clear)
                .border(width: B)
                .color(UIColor.white.withAlphaComponent(0.3))
                .image
                +
                UIImage.size(width: W - B, height: H - B)
                    .corner(radius: (W - B) * 0.5)
                    .border(color: UIColor.white.withAlphaComponent(0.7))
                    .border(width: spaceW * 0.5)
                    .color(.clear)
                    .image)
                .with({ context in
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(L)
                    context.move(to: CGPoint(x: M * shape[0], y: M * shape[1]))
                    context.addLine(to: CGPoint(x: M * shape[2], y: M * shape[3]))
                    context.move(to: CGPoint(x: M * shape[4], y: M * shape[5]))
                    context.addLine(to: CGPoint(x: M * shape[6], y: M * shape[7]))
                    context.strokePath()
                })
            
            imageSelect = UIImage.size(width: W, height: H)
                .corner(radius: W * 0.5)
                .border(color: .clear)
                .border(width: B)
                .color(gradient: [tin.withAlphaComponent(1), tin.withAlphaComponent(1)], locations: [0, 1], from: fromPoint!, to: toPoint!)
                .image
                .with({ context in
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(L)
                    context.move(to: CGPoint(x: M * shape[0], y: M * shape[1]))
                    context.addLine(to: CGPoint(x: M * shape[2], y: M * shape[3]))
                    context.move(to: CGPoint(x: M * shape[4], y: M * shape[5]))
                    context.addLine(to: CGPoint(x: M * shape[6], y: M * shape[7]))
                    context.strokePath()
                })
        case .square:
            imageUnselect = UIImage.size(width: W, height: H)
                .corner(topLeft: 0,
                        topRight: 0,
                        bottomLeft: 0,
                        bottomRight: 0)
                .color(UIColor.white.withAlphaComponent(0.3))
                .image
                .with({ context in
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(L)
                    context.move(to: CGPoint(x: M * shape[0] + addX, y: M * shape[1] + addY))
                    context.addLine(to: CGPoint(x: M * shape[2] + addX, y: M * shape[3] + addY))
                    context.move(to: CGPoint(x: M * shape[4] + addX, y: M * shape[5] + addY))
                    context.addLine(to: CGPoint(x: M * shape[6] + addX, y: M * shape[7] + addY))
                    context.strokePath()
                })
            
            imageSelect = UIImage.size(width: W, height: H)
                .corner(topLeft: 0,
                        topRight: 0,
                        bottomLeft: 0,
                        bottomRight: 0)
                .color(gradient: [tin.withAlphaComponent(1), tin.withAlphaComponent(1)], locations: [0, 1], from: fromPoint!, to: toPoint!)
                .image
                .with({ context in
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(L)
                    context.move(to: CGPoint(x: M * shape[0] + addX, y: M * shape[1] + addY))
                    context.addLine(to: CGPoint(x: M * shape[2] + addX, y: M * shape[3] + addY))
                    context.move(to: CGPoint(x: M * shape[4] + addX, y: M * shape[5] + addY))
                    context.addLine(to: CGPoint(x: M * shape[6] + addX, y: M * shape[7] + addY))
                    context.strokePath()
                })
        case .rectangle:
            addX = (P == .topRight || P == .bottomRight) ? (W * 2 + B * 0.5) : (-B * 0.5)
            addY = -B * 0.5
            W = W * 3
            H = H - B
            imageUnselect = UIImage.size(width: W, height: H)
                .corner(topLeft: 0,
                        topRight: 0,
                        bottomLeft: 0,
                        bottomRight: 0)
                .color(gradient: [UIColor.white.withAlphaComponent(0.6), UIColor.white.withAlphaComponent(0.01)], locations: [0, 1], from: fromPoint!, to: toPoint!)
                .image
                .with({ context in
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(L)
                    context.move(to: CGPoint(x: M * shape[0] + addX, y: M * shape[1] + addY))
                    context.addLine(to: CGPoint(x: M * shape[2] + addX, y: M * shape[3] + addY))
                    context.move(to: CGPoint(x: M * shape[4] + addX, y: M * shape[5] + addY))
                    context.addLine(to: CGPoint(x: M * shape[6] + addX, y: M * shape[7] + addY))
                    context.strokePath()
                })
            
            imageSelect = UIImage.size(width: W, height: H)
                .corner(topLeft: 0,
                        topRight: 0,
                        bottomLeft: 0,
                        bottomRight: 0)
                .color(gradient: [tin.withAlphaComponent(1), UIColor.white.withAlphaComponent(0.01)], locations: [0, 1], from: fromPoint!, to: toPoint!)
                .image
                .with({ context in
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(L)
                    context.move(to: CGPoint(x: M * shape[0] + addX, y: M * shape[1] + addY))
                    context.addLine(to: CGPoint(x: M * shape[2] + addX, y: M * shape[3] + addY))
                    context.move(to: CGPoint(x: M * shape[4] + addX, y: M * shape[5] + addY))
                    context.addLine(to: CGPoint(x: M * shape[6] + addX, y: M * shape[7] + addY))
                    context.strokePath()
                })
        case .triangleHalfFill:
            let beltLineW = W * 0.5
            W = W * 1.5
            H = H * 1.5
            var beltMoveTo: CGPoint?
            var beltLineTo: CGPoint?
            switch P {
            case .topRight:
                addX = M * (isRemove ? 5.75 : 5)
                addY = -M * (isRemove ? 1 : 2)
                beltMoveTo = CGPoint(x: W * 0.5, y: 0)
                beltLineTo = CGPoint(x: W,       y: H * 0.5)
            case .bottomLeft:
                addX = -M * 1.25
                addY = M * 5.5
                beltMoveTo = CGPoint(x: -W * 0.25, y: H * 0.25)
                beltLineTo = CGPoint(x: W * 0.5,   y: H)
            case .topLeft:
                addX = -M * (isRemove ? 1.25 : 0.5)
                addY = -M * (isRemove ? 1 : 2)
                beltMoveTo = CGPoint(x: W * 0.5, y: 0)
                beltLineTo = CGPoint(x: 0,       y: H * 0.5)
            case .bottomRight:
                addX = M * (isRemove ? 5.25 : 5.75)
                addY = M * (isRemove ? 6 : 5)
                beltMoveTo = CGPoint(x: W,       y: H * 0.5)
                beltLineTo = CGPoint(x: W * 0.5, y: H)
            }
            imageUnselect = UIImage.size(width: W, height: H)
                .color(.clear)
                .image
                .with({ context in
                    context.setLineCap(.square)
                    UIColor.white.withAlphaComponent(0.3).setStroke()
                    context.setLineWidth(beltLineW)
                    context.move(to: beltMoveTo!)
                    context.addLine(to: beltLineTo!)
                    context.strokePath()
                    
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(L)
                    context.move(to: CGPoint(x: M * shape[0] + addX, y: M * shape[1] + addY))
                    context.addLine(to: CGPoint(x: M * shape[2] + addX, y: M * shape[3] + addY))
                    context.move(to: CGPoint(x: M * shape[4] + addX, y: M * shape[5] + addY))
                    context.addLine(to: CGPoint(x: M * shape[6] + addX, y: M * shape[7] + addY))
                    context.strokePath()
                })
            
            imageSelect = UIImage.size(width: W, height: H)
                .color(.clear)
                .image
                .with({ context in
                    context.setLineCap(.square)
                    tin.setStroke()
                    context.setLineWidth(beltLineW)
                    context.move(to: beltMoveTo!)
                    context.addLine(to: beltLineTo!)
                    context.strokePath()
                    
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(L)
                    context.move(to: CGPoint(x: M * shape[0] + addX, y: M * shape[1] + addY))
                    context.addLine(to: CGPoint(x: M * shape[2] + addX, y: M * shape[3] + addY))
                    context.move(to: CGPoint(x: M * shape[4] + addX, y: M * shape[5] + addY))
                    context.addLine(to: CGPoint(x: M * shape[6] + addX, y: M * shape[7] + addY))
                    context.strokePath()
                })
        case .triangleFill:
            let beltLineW = W * 0.75
            var beltMoveTo: CGPoint?
            var beltLineTo: CGPoint?
            switch P {
            case .topRight:
                addX = M * 2
                addY = -M * (isRemove ? 1.75 : 2.5)
                beltMoveTo = CGPoint(x: W * 0.5, y: 0)
                beltLineTo = CGPoint(x: W, y: H * 0.5)
            case .bottomLeft:
                addX = -M * (isRemove ? 2 : 1.75)
                addY = M * (isRemove ? 1.75 : 1.5)
                beltMoveTo = CGPoint(x: -W * 0.25, y: H * 0.25)
                beltLineTo = CGPoint(x: W * 0.5, y: H)
            case .topLeft:
                addX = -M * (isRemove ? 2 : 1.5)
                addY = -M * (isRemove ? 1.75 : 2.5)
                beltMoveTo = CGPoint(x: W * 0.5, y: 0)
                beltLineTo = CGPoint(x: 0, y: H * 0.5)
            case .bottomRight:
                addX = M * (isRemove ? 2 : 1.5)
                addY = M * (isRemove ? 1.75 : 1.5)
                beltMoveTo = CGPoint(x: W, y: H * 0.5)
                beltLineTo = CGPoint(x: W * 0.5, y: H)
            }
            
            imageUnselect = UIImage.size(width: W, height: H)
                .color(.clear)
                .image
                .with({ context in
                    context.setLineCap(.square)
                    UIColor.white.withAlphaComponent(0.3).setStroke()
                    context.setLineWidth(beltLineW)
                    context.move(to: beltMoveTo!)
                    context.addLine(to: beltLineTo!)
                    context.strokePath()
                    
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(L)
                    context.move(to: CGPoint(x: M * shape[0] + addX, y: M * shape[1] + addY))
                    context.addLine(to: CGPoint(x: M * shape[2] + addX, y: M * shape[3] + addY))
                    context.move(to: CGPoint(x: M * shape[4] + addX, y: M * shape[5] + addY))
                    context.addLine(to: CGPoint(x: M * shape[6] + addX, y: M * shape[7] + addY))
                    context.strokePath()
                })
            
            imageSelect = UIImage.size(width: W, height: H)
                .color(.clear)
                .image
                .with({ context in
                    context.setLineCap(.square)
                    tin.setStroke()
                    context.setLineWidth(beltLineW)
                    context.move(to: beltMoveTo!)
                    context.addLine(to: beltLineTo!)
                    context.strokePath()
                    
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(L)
                    context.move(to: CGPoint(x: M * shape[0] + addX, y: M * shape[1] + addY))
                    context.addLine(to: CGPoint(x: M * shape[2] + addX, y: M * shape[3] + addY))
                    context.move(to: CGPoint(x: M * shape[4] + addX, y: M * shape[5] + addY))
                    context.addLine(to: CGPoint(x: M * shape[6] + addX, y: M * shape[7] + addY))
                    context.strokePath()
                })
        case .heart:
            let spaceW = W/8
            let radius = (W-spaceW*2)/4
            let leftCenter = CGPoint(x: spaceW+radius, y: spaceW+radius)
            let rightCenter = CGPoint(x: spaceW+radius*3, y: spaceW+radius)
            
            imageUnselect = UIImage.size(width: W, height: H)
                .color(.clear)
                .image
                .with({ context in
                    let heartLine = UIBezierPath(arcCenter: leftCenter, radius: radius, startAngle: CGFloat(Double.pi), endAngle: 0, clockwise: true)
                    heartLine.addArc(withCenter: rightCenter, radius: radius, startAngle: CGFloat(Double.pi), endAngle: 0, clockwise: true)
                    heartLine.addQuadCurve(to: CGPoint(x: W/2, y: H-spaceW*2), controlPoint: CGPoint(x: W-spaceW, y: H*0.6))
                    heartLine.addQuadCurve(to: CGPoint(x: spaceW, y: spaceW+radius), controlPoint: CGPoint(x: spaceW, y: H*0.6))
                    context.addPath(heartLine.cgPath)
                    context.setLineCap(.round)
                    UIColor.white.withAlphaComponent(0.7).setStroke()
                    context.setLineWidth(L)
                    context.strokePath()
                })
            imageSelect = UIImage.size(width: W, height: H)
                .color(.clear)
                .image
                .with({ context in
                    let heartLine = UIBezierPath(arcCenter: leftCenter, radius: radius, startAngle: CGFloat(Double.pi), endAngle: 0, clockwise: true)
                    heartLine.addArc(withCenter: rightCenter, radius: radius, startAngle: CGFloat(Double.pi), endAngle: 0, clockwise: true)
                    heartLine.addQuadCurve(to: CGPoint(x: W/2, y: H-spaceW*2), controlPoint: CGPoint(x: W-spaceW, y: H*0.6))
                    heartLine.addQuadCurve(to: CGPoint(x: spaceW, y: spaceW+radius), controlPoint: CGPoint(x: spaceW, y: H*0.6))
                    context.addPath(heartLine.cgPath)
                    context.setLineCap(.round)
                    tin.set()
                    context.fillPath()
                })
        case .star:
            let spaceW = W/10
            let centerPoint = CGPoint(x: W * 0.5, y: H * 0.5)
            let radius: Float = Float(W * 0.5 - spaceW)
            var p = CGPoint(x: centerPoint.x, y: centerPoint.y-CGFloat(radius))
            let angle: Float = Float(4 * Double.pi / 5.0);
            
            imageUnselect = UIImage.size(width: W, height: H)
                .color(.clear)
                .border(color: UIColor.white.withAlphaComponent(0.7))
                .border(width: 1.5)
                .corner(radius: W * 0.5)
                .image
                .with({ context in
                    context.setLineCap(.round)
                    UIColor.white.withAlphaComponent(0.3).setFill()
                    context.setLineWidth(L)
                    context.move(to: p)
                    for i in 1...5{
                        let x = centerPoint.x - CGFloat(sinf(Float(i) * angle) * radius)
                        let y = centerPoint.y - CGFloat(cosf(Float(i) * angle) * radius)
                        context.addLine(to: CGPoint(x: (p.x + x)/2 + (i == 2 || i == 5 ? L : -L), y: (p.y + y)/2 + (i == 3 ? -L : 0) ))
                        p = CGPoint(x: x, y: y)
                        context.addLine(to: p)
                    }
                    context.fillPath()
                })
            imageSelect = UIImage.size(width: W, height: H)
                .color(.clear)
                .image
                .with({ context in
                    context.setLineCap(.round)
                    tin.setFill()
                    context.move(to: p)
                    for i in 1...5{
                        let x = centerPoint.x - CGFloat(sinf(Float(i) * angle) * radius)
                        let y = centerPoint.y - CGFloat(cosf(Float(i) * angle) * radius)
                        context.addLine(to: CGPoint(x: (p.x + x)/2 + (i == 2 || i == 5 ? L : -L), y: (p.y + y)/2 + (i == 3 ? -L : 0) ))
                        p = CGPoint(x: x, y: y)
                        context.addLine(to: p)
                    }
                    context.fillPath()
                })
        }
        
        return(imageSelect!,imageUnselect!,CGSize(width: W, height: H))
    }
    
}

public enum BorderAlignment {
    case inside
    case center
    case outside
}

public extension UIImage {
    typealias ContextBlock = (CGContext) -> Void
    
    class func with(width: CGFloat, height: CGFloat, block: ContextBlock) -> UIImage {
        return self.with(size: CGSize(width: width, height: height), block: block)
    }
    
    class func with(size: CGSize, opaque: Bool = false, scale: CGFloat = 0, block: ContextBlock) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()!
        block(context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    func with(size: CGSize, opaque: Bool = false, scale: CGFloat = 0, block: ContextBlock) -> UIImage {
        return self + UIImage.with(size:size,opaque:opaque,scale:scale,block:block)
    }
    
    func with(_ block: ContextBlock) -> UIImage {
        return UIImage.with(size: self.size, opaque: false, scale: self.scale) { context in
            let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
            self.draw(in: rect)
            block(context)
        }
    }
    
    func with(color: UIColor) -> UIImage {
        return UIImage.with(size: self.size) { context in
            context.translateBy(x: 0, y: self.size.height)
            context.scaleBy(x: 1, y: -1)
            context.setBlendMode(.normal)
            let rect = CGRect(origin: .zero, size: self.size)
            context.clip(to: rect, mask: self.cgImage!)
            color.setFill()
            context.fill(rect)
        }
    }
    
    class func size(width: CGFloat, height: CGFloat) -> TGImagePresenter {
        return self.size(CGSize(width: width, height: height))
    }
    
    class func size(_ size: CGSize) -> TGImagePresenter {
        let drawer = TGImagePresenter()
        drawer.size = .fixed(size)
        return drawer
    }
    
    class func resizable() -> TGImagePresenter {
        let drawer = TGImagePresenter()
        drawer.size = .resizable
        return drawer
    }
    
    private struct AssociatedKeys {
        static var TGImagePositionKey = "TGImagePositionKey"
    }
    
    var position: CGPoint{
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.TGImagePositionKey) as? CGPoint ?? CGPoint.zero
        }
        set(newValue) {
            if self.position != newValue{
                self.willChangeValue(forKey: "position")
                objc_setAssociatedObject(self, &AssociatedKeys.TGImagePositionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                self.didChangeValue(forKey: "position")
            }
        }
    }
    
    func position(_ point:CGPoint) -> UIImage{
        self.position = point
        return self
    }
}

extension UIColor{
    public class func randomColor() -> UIColor{
        return UIColor(red: CGFloat(arc4random_uniform(255))/255.0, green: CGFloat(arc4random_uniform(255))/255.0, blue: CGFloat(arc4random_uniform(255))/255.0, alpha: 1.0)
    }
}

public func + (leftImage: UIImage, rigthImage: UIImage) -> UIImage {
    return leftImage.with { context in
        
        let leftRect = CGRect(x: 0, y: 0, width: leftImage.size.width, height: leftImage.size.height)
        var rightRect = CGRect(x: 0, y: 0, width: rigthImage.size.width, height: rigthImage.size.height)
        
        if rigthImage.position.x != 0 || rigthImage.position.y != 0{
            rightRect.origin.x = rigthImage.position.x
            rightRect.origin.y = rigthImage.position.y
        }else if leftRect.contains(rightRect) {
            rightRect.origin.x = (leftRect.size.width - rightRect.size.width) / 2
            rightRect.origin.y = (leftRect.size.height - rightRect.size.height) / 2
        } else {
            rightRect.size = leftRect.size
        }
        
        rigthImage.draw(in: rightRect)
    }
}

public func += (leftImage:inout UIImage, rigthImage: UIImage) {
    leftImage = leftImage + rigthImage
}

open class TGImagePresenter {
    public enum Size {
        case fixed(CGSize)
        case resizable
    }
    
    public static let defaultGradientLocations: [CGFloat] = [0, 1]
    public static let defaultGradientFrom: CGPoint = .zero
    public static let defaultGradientTo: CGPoint = CGPoint(x: 0, y: 1)
    
    fileprivate var colors: [UIColor] = [.clear]
    fileprivate var colorLocations: [CGFloat] = defaultGradientLocations
    fileprivate var colorStartPoint: CGPoint = defaultGradientFrom
    fileprivate var colorEndPoint: CGPoint = defaultGradientTo
    fileprivate var borderColors: [UIColor] = [.black]
    fileprivate var borderColorLocations: [CGFloat] = defaultGradientLocations
    fileprivate var borderColorStartPoint: CGPoint = defaultGradientFrom
    fileprivate var borderColorEndPoint: CGPoint = defaultGradientTo
    fileprivate var borderWidth: CGFloat = 0
    fileprivate var borderAlignment: BorderAlignment = .inside
    fileprivate var cornerRadiusTopLeft: CGFloat = 0
    fileprivate var cornerRadiusTopRight: CGFloat = 0
    fileprivate var cornerRadiusBottomLeft: CGFloat = 0
    fileprivate var cornerRadiusBottomRight: CGFloat = 0
    
    fileprivate var size: Size = .resizable
    
    private static var cachedImages = [String: UIImage]()
    
    private var cacheKey: String {
        var attributes = [String: String]()
        attributes["colors"] = String(self.colors.description.hashValue)
        attributes["colorLocations"] = String(self.colorLocations.description.hashValue)
        attributes["colorStartPoint"] = String(String(describing: self.colorStartPoint).hashValue)
        attributes["colorEndPoint"] = String(String(describing: self.colorEndPoint).hashValue)
        attributes["borderColors"] = String(self.borderColors.description.hashValue)
        attributes["borderColorLocations"] = String(self.borderColorLocations.description.hashValue)
        attributes["borderColorStartPoint"] = String(String(describing: self.borderColorStartPoint).hashValue)
        attributes["borderColorEndPoint"] = String(String(describing: self.borderColorEndPoint).hashValue)
        attributes["borderWidth"] = String(self.borderWidth.hashValue)
        attributes["borderAlignment"] = String(self.borderAlignment.hashValue)
        attributes["cornerRadiusTopLeft"] = String(self.cornerRadiusTopLeft.hashValue)
        attributes["cornerRadiusTopRight"] = String(self.cornerRadiusTopRight.hashValue)
        attributes["cornerRadiusBottomLeft"] = String(self.cornerRadiusBottomLeft.hashValue)
        attributes["cornerRadiusBottomRight"] = String(self.cornerRadiusBottomRight.hashValue)
        
        switch self.size {
        case .fixed(let size):
            attributes["size"] = "Fixed(\(size.width), \(size.height))"
        case .resizable:
            attributes["size"] = "Resizable"
        }
        
        var serializedAttributes = [String]()
        for key in attributes.keys.sorted() {
            if let value = attributes[key] {
                serializedAttributes.append("\(key):\(value)")
            }
        }
        
        let cacheKey = serializedAttributes.joined(separator: "|")
        return cacheKey
    }
    
    open func color(_ color: UIColor) -> Self {
        self.colors = [color]
        return self
    }
    
    open func color(gradient: [UIColor],locations: [CGFloat] = TGImagePresenter.defaultGradientLocations,from startPoint: CGPoint = TGImagePresenter.defaultGradientFrom,to endPoint: CGPoint = TGImagePresenter.defaultGradientTo) -> Self {
        self.colors = gradient
        self.colorLocations = locations
        self.colorStartPoint = startPoint
        self.colorEndPoint = endPoint
        return self
    }
    
    open func border(color: UIColor) -> Self {
        self.borderColors = [color]
        return self
    }
    
    open func border(gradient: [UIColor],locations: [CGFloat] = TGImagePresenter.defaultGradientLocations,from startPoint: CGPoint = TGImagePresenter.defaultGradientFrom,to endPoint: CGPoint = TGImagePresenter.defaultGradientTo
        ) -> Self {
        self.borderColors = gradient
        self.borderColorLocations = locations
        self.borderColorStartPoint = startPoint
        self.borderColorEndPoint = endPoint
        return self
    }
    
    open func border(width: CGFloat) -> Self {
        self.borderWidth = width
        return self
    }
    
    open func border(alignment: BorderAlignment) -> Self {
        self.borderAlignment = alignment
        return self
    }
    
    open func corner(radius: CGFloat) -> Self {
        return self.corner(topLeft: radius, topRight: radius, bottomLeft: radius, bottomRight: radius)
    }
    
    open func corner(topLeft: CGFloat) -> Self {
        self.cornerRadiusTopLeft = topLeft
        return self
    }
    
    open func corner(topRight: CGFloat) -> Self {
        self.cornerRadiusTopRight = topRight
        return self
    }
    
    open func corner(bottomLeft: CGFloat) -> Self {
        self.cornerRadiusBottomLeft = bottomLeft
        return self
    }
    
    open func corner(bottomRight: CGFloat) -> Self {
        self.cornerRadiusBottomRight = bottomRight
        return self
    }
    
    open func corner(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) -> Self {
        return self.corner(topLeft: topLeft).corner(topRight: topRight).corner(bottomLeft: bottomLeft).corner(bottomRight: bottomRight)
    }
    
    open var image: UIImage {
        switch self.size {
        case .fixed(let size):
            return self.imageWithSize(size)
        case .resizable:
            self.borderAlignment = .inside
            let cornerRadius = max(self.cornerRadiusTopLeft, self.cornerRadiusTopRight,self.cornerRadiusBottomLeft, self.cornerRadiusBottomRight)
            let capSize = ceil(max(cornerRadius, self.borderWidth))
            let imageSize = capSize * 2 + 1
            let image = self.imageWithSize(CGSize(width: imageSize, height: imageSize))
            let capInsets = UIEdgeInsets(top: capSize, left: capSize, bottom: capSize, right: capSize)
            return image.resizableImage(withCapInsets: capInsets)
        }
    }
    
    private func imageWithSize(_ size: CGSize, useCache: Bool = true) -> UIImage {
        if let cachedImage = type(of: self).cachedImages[self.cacheKey], useCache {
            return cachedImage
        }
        
        var imageSize = CGSize(width: size.width, height: size.height)
        var rect = CGRect()
        rect.size = imageSize
        
        switch self.borderAlignment {
        case .inside:
            rect.origin.x += self.borderWidth / 2
            rect.origin.y += self.borderWidth / 2
            rect.size.width -= self.borderWidth
            rect.size.height -= self.borderWidth
        case .center:
            rect.origin.x += self.borderWidth / 2
            rect.origin.y += self.borderWidth / 2
            imageSize.width += self.borderWidth
            imageSize.height += self.borderWidth
        case .outside:
            rect.origin.x += self.borderWidth / 2
            rect.origin.y += self.borderWidth / 2
            rect.size.width += self.borderWidth
            rect.size.height += self.borderWidth
            imageSize.width += self.borderWidth * 2
            imageSize.height += self.borderWidth * 2
        }
        
        let cornerRadius = max(self.cornerRadiusTopLeft, self.cornerRadiusTopRight,self.cornerRadiusBottomLeft, self.cornerRadiusBottomRight)
        
        let image = UIImage.with(size: imageSize) { context in
            let path: UIBezierPath
            if self.cornerRadiusTopLeft == self.cornerRadiusTopRight && self.cornerRadiusTopLeft == self.cornerRadiusBottomLeft && self.cornerRadiusTopLeft == self.cornerRadiusBottomRight && self.cornerRadiusTopLeft > 0 {
                path = UIBezierPath(roundedRect: rect, cornerRadius: self.cornerRadiusTopLeft)
            } else if cornerRadius > 0 {
                let startAngle = CGFloat.pi
                let topLeftCenter = CGPoint(x: self.cornerRadiusTopLeft + self.borderWidth / 2,y: self.cornerRadiusTopLeft + self.borderWidth / 2)
                let topRightCenter = CGPoint(x: imageSize.width - self.cornerRadiusTopRight - self.borderWidth / 2,y: self.cornerRadiusTopRight + self.borderWidth / 2)
                let bottomRightCenter = CGPoint(x: imageSize.width - self.cornerRadiusBottomRight - self.borderWidth / 2,y: imageSize.height - self.cornerRadiusBottomRight - self.borderWidth / 2)
                let bottomLeftCenter = CGPoint(x: self.cornerRadiusBottomLeft + self.borderWidth / 2,y: imageSize.height - self.cornerRadiusBottomLeft - self.borderWidth / 2)
                let mutablePath = UIBezierPath()
                self.cornerRadiusTopLeft > 0 ? mutablePath.addArc(withCenter: topLeftCenter,radius: self.cornerRadiusTopLeft,startAngle: startAngle,endAngle: 1.5 * startAngle,clockwise: true) : mutablePath.move(to: topLeftCenter)
                self.cornerRadiusTopRight > 0 ? mutablePath.addArc(withCenter: topRightCenter,radius: self.cornerRadiusTopRight,startAngle: 1.5 * startAngle,endAngle: 2 * startAngle,clockwise: true) : mutablePath.addLine(to: topRightCenter)
                self.cornerRadiusBottomRight > 0 ? mutablePath.addArc(withCenter: bottomRightCenter,radius: self.cornerRadiusBottomRight,startAngle: 2 * startAngle,endAngle: 2.5 * startAngle,clockwise: true) : mutablePath.addLine(to: bottomRightCenter)
                self.cornerRadiusBottomLeft > 0 ? mutablePath.addArc(withCenter: bottomLeftCenter,radius: self.cornerRadiusBottomLeft,startAngle: 2.5 * startAngle,endAngle: 3 * startAngle,clockwise: true) : mutablePath.addLine(to: bottomLeftCenter)
                self.cornerRadiusTopLeft > 0 ? mutablePath.addLine(to: CGPoint(x: self.borderWidth / 2, y: topLeftCenter.y)) : mutablePath.addLine(to: topLeftCenter)
                path = mutablePath
            }
            else {
                path = UIBezierPath(rect: rect)
            }
            
            context.saveGState()
            if self.colors.count <= 1 {
                self.colors.first?.setFill()
                path.fill()
            } else {
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let colors = self.colors.map { $0.cgColor } as CFArray
                if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: self.colorLocations) {
                    let startPoint = CGPoint(x: self.colorStartPoint.x * imageSize.width,y: self.colorStartPoint.y * imageSize.height)
                    let endPoint = CGPoint(x: self.colorEndPoint.x * imageSize.width,y: self.colorEndPoint.y * imageSize.height)
                    context.addPath(path.cgPath)
                    context.clip()
                    context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
                }
            }
            context.restoreGState()
            
            context.saveGState()
            if self.borderColors.count <= 1 {
                self.borderColors.first?.setStroke()
                path.lineWidth = self.borderWidth
                path.stroke()
            } else {
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let colors = self.borderColors.map { $0.cgColor } as CFArray
                if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: self.borderColorLocations) {
                    let startPoint = CGPoint(x: self.borderColorStartPoint.x * imageSize.width,y: self.borderColorStartPoint.y * imageSize.height)
                    let endPoint = CGPoint(x: self.borderColorEndPoint.x * imageSize.width,y: self.borderColorEndPoint.y * imageSize.height)
                    context.addPath(path.cgPath)
                    context.setLineWidth(self.borderWidth)
                    context.replacePathWithStrokedPath()
                    context.clip()
                    context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
                }
            }
            context.restoreGState()
        }
        
        if useCache {
            type(of: self).cachedImages[self.cacheKey] = image
        }
        return image
    }
}

