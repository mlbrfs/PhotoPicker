//
//  AlbumManager.swift
//  PhotoPicker
//
//  Created by 马磊 on 2019/1/17.
//  Copyright © 2019 MLCode. All rights reserved.
//

import UIKit
import Photos


class AlbumManager {

    var photoFetchOptions: PHFetchOptions {
        let fetch = PHFetchOptions()
        switch PhotoPickerManager.shared.options.allowFileType {
        case .all: break
        case .onlyPhoto:
            fetch.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        case .onlyVideo:
            fetch.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        case .onlyLive:
            if #available(iOS 9.1, *) {
                fetch.predicate = NSPredicate(format: "mediaSubtype == %d", PHAssetMediaSubtype.photoLive.rawValue)
            }
        }
        return fetch
    }
    
    
    func loadAlbums() -> [Fetch] {
        
        var albums: [Fetch] = []
        
        func fetchResult(_ collection: PHAssetCollection) {
            let result = PHAsset.fetchAssets(in: collection, options: photoFetchOptions)
            if result.count > 0 { // album is not Empty
                let fetch = Fetch(result: result, name: LocalizableString.localizedString(for: collection.localizedTitle, type: collection.assetCollectionSubtype), assetType: collection.assetCollectionSubtype)
                if collection.assetCollectionSubtype == .smartAlbumUserLibrary || collection.localizedTitle == "All Photos" {
                    albums.insert(fetch, at: 0)
                } else {
                    albums.append(fetch)
                }
            }
        }
        
        let smartAlbums: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        for i in 0 ..< smartAlbums.count {//(contains `Recently Deleted`)
            if PhotoPickerManager.shared.options.isAlbumSmartCollections {
                if [PHAssetCollectionSubtype.smartAlbumUserLibrary, .smartAlbumRecentlyAdded].contains(smartAlbums[i].assetCollectionSubtype) {
                    fetchResult(smartAlbums[i])
                }
            } else {
                    fetchResult(smartAlbums[i])
            }
        }
        let topUserLibrary = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        for i in 0 ..< topUserLibrary.count {
            if let topUserAlbumItem = topUserLibrary[i] as? PHAssetCollection {
                fetchResult(topUserAlbumItem)
            }
        }
        return albums
    }
    
    
    fileprivate(set) var selectedFetch: [PHAsset] = [] {
        didSet {
            if oldValue.count > selectedFetch.count {
                
                let changed = oldValue.filter { selectedFetch.firstIndex(of: $0) == nil }
                
                NotificationCenter.default.post(name: AlbumManager.albumSelectedFetchDidChanged, object: nil, userInfo: [
                    AlbumManager.albumSelectedFetchChangedKey : AlbumSelectedFetchChanged.decrease,
                    AlbumManager.albumSelectedFetchChangedValueKey: [changed]
                    ])
            } else {
                NotificationCenter.default.post(name: AlbumManager.albumSelectedFetchDidChanged, object: nil, userInfo: [
                    AlbumManager.albumSelectedFetchChangedKey : AlbumSelectedFetchChanged.append
                    ])
            }
        }
    }
    
    func isSelect(_ asset: PHAsset) -> Bool {
        return selectedFetch.reduce(false) {
            return $0 ? $0 : $1.localIdentifier == asset.localIdentifier
        }
    }
    
    var isAllowAppendPhotos: Bool {
        return PhotoPickerManager.shared.options.optionsAllowed > selectedFetch.count
    }
    func showDisableAddPhotosAlert() {
        AlertManager.alert(allowPhotos: PhotoPickerManager.shared.navigationController!, title: LocalizableString.exceededImagesaAvailable) 
    }
    
    
    func append(_ asset: PHAsset) {
        if !isAllowAppendPhotos {
            showDisableAddPhotosAlert()
            return
        }
        
        if isSelect(asset) { return }
        selectedFetch.append(asset)
    }
    
    func delete(_ asset: PHAsset) {
        guard let index = index(of: asset) else { return }
        selectedFetch.remove(at: index)
    }
    
    func index(of asset: PHAsset) -> Int? {
        return selectedFetch.firstIndex(of: asset)
    }
    
    func clear() {
        selectedFetch = []
    }
    
}

extension AlbumManager {
    
    class func getImages(with assets: [PHAsset], callback: (([PhotoPickerManagerMediaItem])->())?) {
        
        let smallOptions = PHImageRequestOptions()
        smallOptions.deliveryMode = .highQualityFormat
        smallOptions.resizeMode = .fast
        
        
        let bigOptions = PHImageRequestOptions()
        bigOptions.deliveryMode = .highQualityFormat
        bigOptions.resizeMode = .exact
        
        let imageManeger = PHImageManager()
        
        var items: [PhotoPickerManagerMediaItem] = []
        for assetCase in assets.enumerated() {
            let asset = assetCase.element
            let smallSize = CGSize(width: PhotoPickerManager.shared.options.compressRate * Double(asset.pixelWidth), height: PhotoPickerManager.shared.options.compressRate * Double(asset.pixelHeight))
            let bigSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            var item = PhotoPickerManagerMediaItem()
            item[.phAsset] = asset
            item[.mediaType] = asset.mediaType
            item[.index] = assetCase.offset
            /// 这里还要添加 URL 以及其他数据
            
            imageManeger.requestImage(for: asset, targetSize: bigSize, contentMode: .aspectFit, options: bigOptions, resultHandler: { (bigImage, info) in
                item[.originalImage] = bigImage
                imageManeger.requestImage(for: asset, targetSize: smallSize, contentMode: .aspectFit, options: smallOptions, resultHandler: { (smallImage, info) in
                    item[.smallImage] = smallImage
                    imageManeger.requestImageData(for: asset, options: bigOptions, resultHandler: { (data, str, imageOrientation, info) in
                        item[.metaData] = data
                        
                        let videoOptions = PHVideoRequestOptions()
                        videoOptions.version = PHVideoRequestOptionsVersion.current
                        videoOptions.deliveryMode = PHVideoRequestOptionsDeliveryMode.automatic
                        imageManeger.requestAVAsset(forVideo: asset, options: videoOptions, resultHandler: { (avAsset, _, _) in
                            item[.mediaURL] = (avAsset as? AVURLAsset)?.url
                            if #available(iOS 9.1, *) {
                                let liveOptions = PHLivePhotoRequestOptions()
                                liveOptions.version = PHImageRequestOptionsVersion.current
                                liveOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
                                imageManeger.requestLivePhoto(for: asset, targetSize: bigSize, contentMode: .aspectFit, options: liveOptions, resultHandler: { (live, _) in
                                    item[.livePhoto] = live

                                    items.append(item)
                                    if items.count == assets.count{
                                        DispatchQueue.main.async {
                                            callback?(items.sorted(by: { ($0[.index] as! Int) < ($1[.index] as! Int) }))
                                        }
                                    }
                                })
                            } else {
                                items.append(item)
                                if items.count == assets.count{
                                    DispatchQueue.main.async {
                                        callback?(items.sorted(by: { ($0[.index] as! Int) < ($1[.index] as! Int) }))
                                    }
                                }
                            }
                            
                        })
                        
                        
                    })
                })
            })
        }
    }
    
    private class func getImage(manager: PHImageManager, info: PhotoPickerManagerMediaItem, targetSize: CGSize, options: PHImageRequestOptions, resultHandler: ((UIImage?)->())?) {
        
        manager.requestImage(for: info[.phAsset] as! PHAsset, targetSize: targetSize, contentMode: .aspectFill, options: options) { (image, _) in
           resultHandler?(image)
        }
        
    }
    
    
    
    static func getNewTimeFromDuration(duration:Double) -> String{
        var newTimer = ""
        if duration < 10 {
            newTimer = String(format: "0:0%d", arguments: [Int(duration)])
            return newTimer
        } else if duration < 60 && duration >= 10 {
            newTimer = String(format: "0:%.0f", arguments: [duration])
            return newTimer
        } else {
            let min = Int(duration/60)
            let sec = Int(duration - (Double(min)*60))
            if sec < 10 {
                newTimer = String(format: "%d:0%d", arguments: [min ,sec])
                return newTimer
            } else {
                newTimer = String(format: "%d:%d", arguments: [min ,sec])
                return newTimer
            }
        }
    }
    
}

extension AlbumManager {
    
    static let albumSelectedFetchDidChanged = NSNotification.Name.init(rawValue: "AlbumManager.albumSelectedFetchDidChanged")
    static let albumSelectedFetchChangedKey = "AlbumManager.albumSelectedFetchChangedKey"
    static let albumSelectedFetchChangedValueKey = "AlbumManager.albumSelectedFetchChangedValueKey"
    struct AlbumSelectedFetchChanged {
        static let append = "AlbumSelectedFetchChanged.append"
        static let decrease = "AlbumSelectedFetchChanged.decrease"
    }
}

class Fetch {
    var fetchResult: PHFetchResult<PHAsset>
    var assetType: PHAssetCollectionSubtype
    var name: String
    
    init(result: PHFetchResult<PHAsset>,name: String?, assetType: PHAssetCollectionSubtype){
        self.fetchResult = result
        self.name = name ?? ""
        self.assetType = assetType
    }
    
    func index(asset: PHAsset) -> Int? {
        if fetchResult.contains(asset) {
            fetchResult.index(of: asset)
        }
        return nil
    }
    
}

class Asset {
    
    let asset: PHAsset
    
    var imageScale: CGFloat {
        return CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
    }
    
    init(asset: PHAsset) {
        self.asset = asset
    }
    
}
