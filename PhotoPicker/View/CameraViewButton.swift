//
//  CameraViewButton.swift
//  PhotoPicker
//
//  Created by 马磊 on 2019/1/25.
//  Copyright © 2019 MLCode. All rights reserved.
//

import UIKit

class CameraViewButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(centerView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let centerView = UIView().then {
        $0.backgroundColor = UIColor.white
        $0.isUserInteractionEnabled = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let centWH = frame.size.width * 0.6
        let xy = (frame.size.width - centWH) * 0.5
        centerView.frame = CGRect(x: xy , y: xy, width: centWH, height: centWH)
        centerView.layer.cornerRadius = centWH * 0.5
        centerView.layer.masksToBounds = true
    }
    
    var progress: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var tintColor: UIColor! {
        get {
            return super.tintColor
        }
        set {
            super.tintColor = PhotoPickerManager.shared.options.tintColor.withAlphaComponent(0.9)
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let color: UIColor = tintColor
        color.set()
        
        let xCenter = rect.size.width * 0.5
        let yCenter = rect.size.height * 0.5
        
        
        let to: CGFloat = CGFloat(-Double.pi) * 0.5 + self.progress * CGFloat(Double.pi) * 2
        let radius: CGFloat = rect.size.width * 0.5 - 1
        
        let aPath = UIBezierPath(arcCenter: CGPoint(x: xCenter, y: yCenter), radius: radius,
                                 startAngle: to, endAngle: CGFloat(-Double.pi) * 0.5, clockwise: false)
        aPath.lineWidth = 5.0 // 线条宽度
        aPath.stroke()
        
    }
    
}

class CameraViewDoneButton: UIButton {
    
    lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.isUserInteractionEnabled = false
        return blurView
    }()
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let imageWH: CGFloat = 30
        return CGRect(x: (bounds.size.width - imageWH) * 0.5, y: (bounds.size.height - imageWH) * 0.5, width: imageWH, height: imageWH)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if blurView.window != nil {
            sendSubviewToBack(blurView)
            blurView.frame = bounds
        }
        
    }
    
}
