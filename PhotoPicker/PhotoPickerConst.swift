//
//  PhotoPickerConst.swift
//  PhotoPicker
//
//  Created by 马磊 on 2019/1/17.
//  Copyright © 2019 MLCode. All rights reserved.
//

import UIKit
import Photos

/** 屏幕宽 */
let ScreenW = UIScreen.main.bounds.size.width
/** 屏幕高 */
let ScreenH = UIScreen.main.bounds.size.height

var statusBarHeight: CGFloat {
    return UIApplication.shared.statusBarFrame.size.height
}
/** 头部安全高度34或0 */
var TopSafeHeight: CGFloat {
    return statusBarHeight > 20 ? 34 : 0
}

/** 头部包括状态栏的高度 */
var TopBarHeight: CGFloat {
    return statusBarHeight > 20 ?  (statusBarHeight + 44) : 64
}
/** 底部安全区域 iphoneX 专用 */
var BottomSafeHeight: CGFloat {
    return statusBarHeight > 20 ? 34 : 0
}
/** 底部导航栏高度 */
var BottomBarHeight: CGFloat {
    return statusBarHeight > 20 ? (34 + 49) :  49
}

let PhotoPreviewWH: CGFloat = max(min(250, ScreenW * 0.4), 150)

extension UIColor {
    
    static var tint: UIColor {
        return color(65, 182, 69)
    }
    static var text: UIColor {
        return UIColor.white
    }
    
    static var bar: UIColor {
        return color(46, 46, 46)
    }
    
    class func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> UIColor {
        
        return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
        
    }
    
}

var RandomColor: UIColor {
    return UIColor(red: CGFloat(CGFloat(arc4random_uniform(255)) / 255.0), green: CGFloat(CGFloat(arc4random_uniform(255)) / 255.0), blue: CGFloat(CGFloat(arc4random_uniform(255)) / 255.0), alpha: 1)
}

extension Bundle {
    
    static var current: Bundle {
        let bundle =  Bundle(for: PhotoPickerManager.self)
        let path = bundle.path(forResource: "PhotoPicker", ofType: "bundle")
        let currentBundle =  Bundle(path: path!)
        return currentBundle!
    }
    
}

extension UIImage {
    
    class func bundleImage(named name: String) -> UIImage? {
        return UIImage(contentsOfFile: ((Bundle.current.resourcePath! as NSString).appendingPathComponent(name + ".png"))) ?? UIImage(contentsOfFile: ((Bundle.current.resourcePath! as NSString).appendingPathComponent(name + ".jpg")))
    }
}
