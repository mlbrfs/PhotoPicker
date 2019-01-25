//
//  PhotoPickerOptional.swift
//  PhotoPicker
//
//  Created by 马磊 on 2019/1/17.
//  Copyright © 2019 MLCode. All rights reserved.
//

import UIKit

public typealias PhotoPickerOptions = [PhotoPickerOptionsItem]
let PhotoPickerEmptyOptions = [PhotoPickerOptionsItem]()

public enum PhotoPickerOptionsItem {
    /// default = topRight
    case photoIndicatorPosition(PhotoIndicatorPosition)
    
    /// default = circular
    case photoIndicatorStyle(PhotoIndicatorStyle)
    
    /// allow the file type ,default = all (photo and video)
    case allowType(FileType)
    
    /// default == (UIColor 65 182 69)
    case tintColor(UIColor)
    /// default == (UIColor write)
    case textColor(UIColor)
    
    /// default == (UIColor 46 46 46)
    case barColor(UIColor)
    
    /// default = false, photo sort sequence
    case ascending(Bool)
    
    /// default = false, photo SmartCollections
    /// true use smartAlbumUserLibrary, .smartAlbumRecentlyAdded
    case isUseCustomSmartCollections(Bool)
    /// default = lightContent
    case statusBarStyle(UIStatusBarStyle)
    
    /// default = recent
    case displayMode(DisplayMode)
    
    /// Number of options allowed photo, default = 9
    case optionsAllowed(UInt)
    
    /// default 0.25  value is (0 <--> 1)
    case compressRate(Double)
    
    case autoDismiss(Bool)
    /// sec  allow video size  default = (mix: 1, max: 30)
    case allowVideoSize(min: TimeInterval, max: TimeInterval)
    
}

/// the position is choose photo indicator
public enum PhotoIndicatorPosition {
    /// default
    case topRight
    
    case topLeft
    
    case bottomRight
    
    case bottomLeft
}
/// the style is choose photo indicator
public enum PhotoIndicatorStyle {
    /// default
    case circular
    case square
    case rectangle
    
    case triangleFill
    case triangleHalfFill
    
    case heart
    case star
}

public enum FileType {
    /// default
    case all
    
    case onlyPhoto
    
    case onlyVideo
    
    @available(iOS 9.1, *)
    case onlyLive
}

public enum DisplayMode {
    ///first of album  photos
    case recent
    /// album list
    case list
}

precedencegroup ItemComparisonPrecedence {
    associativity: none
    higherThan: LogicalConjunctionPrecedence
}

infix operator <== : ItemComparisonPrecedence

// This operator returns true if two `PhotoPickerOptionsItem` enum is the same, without considering the associated values.
func <== (lhs: PhotoPickerOptionsItem, rhs: PhotoPickerOptionsItem) -> Bool {
    switch (lhs, rhs) {
    case (.photoIndicatorPosition(_), .photoIndicatorPosition(_)): return true
    case (.photoIndicatorStyle(_), .photoIndicatorStyle(_)): return true
    case (.allowType(_), .allowType(_)): return true
    case (.tintColor(_), .tintColor(_)): return true
    case (.ascending, .ascending): return true
    case (.isUseCustomSmartCollections, .isUseCustomSmartCollections): return true
    case (.displayMode, .displayMode): return true
    case (.textColor, .textColor): return true
    case (.optionsAllowed, .optionsAllowed): return true
    case (.barColor, .barColor): return true
    case (.statusBarStyle, .statusBarStyle): return true
    case (.compressRate, .compressRate): return true
    case (.autoDismiss, .autoDismiss): return true
    default: return false
    }
}


extension Collection where Iterator.Element == PhotoPickerOptionsItem {
    func lastMatchIgnoringAssociatedValue(_ target: Iterator.Element) -> Iterator.Element? {
        return reversed().first { $0 <== target }
    }
    
    func removeAllMatchesIgnoringAssociatedValue(_ target: Iterator.Element) -> [Iterator.Element] {
        return filter { !($0 <== target) }
    }
}

public extension Collection where Iterator.Element == PhotoPickerOptionsItem {
    
    public var allowFileType: FileType {
        if let item = lastMatchIgnoringAssociatedValue(.allowType(.all)),
            case .allowType(let fileType) = item
        {
            return fileType
        }        
        return .all
    }
    
    public var isAscending: Bool {
        if let item = lastMatchIgnoringAssociatedValue(.ascending(false)),
            case .ascending(let isAscending) = item
        {
            return isAscending
        }
        return false
    }
    
    public var indicatorPosition: PhotoIndicatorPosition {
        if let item = lastMatchIgnoringAssociatedValue(.photoIndicatorPosition(.topRight)),
            case .photoIndicatorPosition(let indicatorPosition) = item
        {
            return indicatorPosition
        }
        return .topRight
    }
    public var indicatorStyle: PhotoIndicatorStyle {
        if let item = lastMatchIgnoringAssociatedValue(.photoIndicatorStyle(.circular)),
            case .photoIndicatorStyle(let indicatorStyle) = item
        {
            return indicatorStyle
        }
        return .circular
    }
    
    
    public var isAlbumSmartCollections: Bool {
        if let item = lastMatchIgnoringAssociatedValue(.isUseCustomSmartCollections(false)),
            case .isUseCustomSmartCollections(let isUseCustomSmartCollections) = item
        {
            return isUseCustomSmartCollections
        }
        return false
    }
    public var tintColor: UIColor {
        if let item = lastMatchIgnoringAssociatedValue(.tintColor(UIColor.tint)),
            case .tintColor(let tintColor) = item
        {
            return tintColor
        }
        return UIColor.tint
    }
    
    public var displayMode: DisplayMode {
        if let item = lastMatchIgnoringAssociatedValue(.displayMode(.recent)),
            case .displayMode(let displayMode) = item
        {
            return displayMode
        }
        return .recent
    }
    
    public var textColor: UIColor {
        if let item = lastMatchIgnoringAssociatedValue(.textColor(UIColor.tint)),
            case .textColor(let textColor) = item
        {
            return textColor
        }
        return UIColor.text
    }
    
    public var barColor: UIColor {
        if let item = lastMatchIgnoringAssociatedValue(.barColor(UIColor.tint)),
            case .barColor(let barColor) = item
        {
            return barColor
        }
        return UIColor.bar
    }
    
    public var optionsAllowed: Int {
        if let item = lastMatchIgnoringAssociatedValue(.optionsAllowed(9)),
            case .optionsAllowed(let optionsAllowed) = item
        {
            return Int(optionsAllowed)
        }
        return 9
    }
    
    public var statusBarStyle: UIStatusBarStyle {
        if let item = lastMatchIgnoringAssociatedValue(.statusBarStyle(.lightContent)),
            case .statusBarStyle(let statusBarStyle) = item
        {
            return statusBarStyle
        }
        return .lightContent
    }
    
    public var compressRate: Double {
        if let item = lastMatchIgnoringAssociatedValue(.compressRate(0.25)),
            case .compressRate(let compressRate) = item
        {
            return Swift.max(0, Swift.min(compressRate, 1))
        }
        return 0.25
    }
    public var autoDismiss: Bool {
        if let item = lastMatchIgnoringAssociatedValue(.autoDismiss(true)),
            case .autoDismiss(let autoDismiss) = item
        {
            return autoDismiss
        }
        return true
    }
    
    public var allowVideoSize: (min: TimeInterval, max: TimeInterval) {
        if let item = lastMatchIgnoringAssociatedValue(.allowVideoSize(min: 1, max: 30)),
            case .allowVideoSize(let allowVideoSize) = item
        {
            return allowVideoSize
        }
        return (min: 1, max: 30)
    }
    
    
}
