//
//  LocalizableString.swift
//  PhotoPicker
//
//  Created by 马磊 on 2019/1/23.
//  Copyright © 2019 MLCode. All rights reserved.
//

import UIKit
import Photos

extension Bundle {
    
    class func localizedString(for key: String, value: String? = nil) -> String {
        
        var language: String
        language = Locale.preferredLanguages.first ?? "en"
        if language.hasPrefix("en") == true {
            language = "en"
        } else if language.hasPrefix("zh") == true  {
            language = "zh-Hans"
        } else {
            language = "en"
        }
        
        let bundle = Bundle(path: current.path(forResource: language, ofType: "lproj")!)!
        let str = bundle.localizedString(forKey: key, value: value, table: nil)
        return str
    }
    
    fileprivate class func localizedString(for key: String?, type: PHAssetCollectionSubtype) -> String {
        
        var language: String
        language = Locale.preferredLanguages.first ?? "en"
        if language.hasPrefix("zh") == true {
            return getAlbumName(type, key)
        } else {
            return localizedString(for: key ?? "")
        }
        
    }
    
}

struct LocalizableString  { }

extension LocalizableString {
    
    static var cancel: String { return Bundle.localizedString(for: "Cancel") }

    static var finish: String { return Bundle.localizedString(for: "Finish") }
    static var sure: String { return Bundle.localizedString(for: "Sure") }

    static var choosePicture: String { return Bundle.localizedString(for: "ChoosePicture") }
    
    static var photoAlbum: String { return Bundle.localizedString(for: "PhotoAlbum") }

    static var camera: String { return Bundle.localizedString(for: "Camera") }
    
    static var empty: String { return Bundle.localizedString(for: "LocalAlbumEmpty") }
    static var albumReject: String { return Bundle.localizedString(for: "LocalAlbumReject") }
    static var waitAuthorization: String { return Bundle.localizedString(for: "WaitAuthorization") }
    
    static var cameraReject: String { return Bundle.localizedString(for: "CameraReject") }
    static var cameraDisable: String { return Bundle.localizedString(for: "CameraDisable") }
    static func localizedString(for key: String?, type: PHAssetCollectionSubtype) -> String {
        return Bundle.localizedString(for: key, type: type)
    }
    
    static var exceededImagesaAvailable: String { return Bundle.localizedString(for: "ExceededImagesaAvailable") }
    
    static var preview: String { return Bundle.localizedString(for: "Preview") }
    
    static var recordingFailed: String { return Bundle.localizedString(for: "RecordingFailed") }
    
    static var lessThanRecordTime: String { return Bundle.localizedString(for: "LessThanRecordTime") }
    static var second: String { return Bundle.localizedString(for: "Second") }
    
}

fileprivate func getAlbumName(_ type: PHAssetCollectionSubtype, _ name: String? = "") -> String {
    switch type {
    case .smartAlbumPanoramas:
        return "全景照片"
    case .smartAlbumVideos:
        return "视频"
    case .smartAlbumFavorites:
        return "个人收藏"
    case .smartAlbumTimelapses:
        return "延时摄影"
    case .smartAlbumAllHidden:
        return "隐藏"
    case .smartAlbumRecentlyAdded:
        return "最近添加"
    case .smartAlbumBursts:
        return "连拍快照"
    case .smartAlbumSlomoVideos:
        return "慢动作"
    case .smartAlbumUserLibrary:
        return "所有照片"//相机胶卷
    case .smartAlbumSelfPortraits:
        return "自拍"
    case .smartAlbumScreenshots:
        return "屏幕快照"
    case .smartAlbumDepthEffect:
        return "景深效果"
    case .smartAlbumLivePhotos:
        return "Live Photo"
    default:
        switch name {
        case "Recently Deleted":
            return "最近删除"
        case "All Photos":
            return "所有照片"
        case "Camera Roll":
            return "相机胶卷"
        case "Favorites":
            return "收藏"
        case "Videos":
            return "视频"
        case "Recently Added":
            return "最近添加"
        case "Selfies":
            return "自拍"
        case "Screenshots":
            return "屏幕快照"
        case "Panoramas":
            return "全景照片"
        case "Slo-mo":
            return "慢动作"
        case "Bursts":
            return "连拍快照"
        case "Hidden":
            return "隐藏"
        case "Time-lapse":
            return "延时摄影"
        case "Live Photos":
            return "生活"
        case "Depth Effect":
            return "景深效果"
        default:
            return name ?? ""
        }
    }
}
