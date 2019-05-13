//
//  PhotoPickerManager.swift
//  PhotoPicker
//
//  Created by 马磊 on 2019/1/17.
//  Copyright © 2019 MLCode. All rights reserved.
//

import UIKit
import Photos

public enum PhotoPickerState {
    
    case all
    case camera
    case library
    
}

public typealias PhotoPickerManagerMediaItem = [PhotoPickerManager.InfoKey: Any]

public protocol PhotoPickerManagerDelegate: class {
    func photoPickerManager(_ photoPickerManager: PhotoPickerManager, didFinishPickingMediaWithInfo info: [PhotoPickerManagerMediaItem])
}
public extension PhotoPickerManagerDelegate {
    func photoPickerManager(_ photoPickerManager: PhotoPickerManager, didFinishPickingMediaWithInfo info: [PhotoPickerManagerMediaItem]) { }
    
}


/** 图片选择管理器 */
open class PhotoPickerManager: NSObject {
    
    public static fileprivate(set) var shared = PhotoPickerManager()
    
    public fileprivate(set) var options: PhotoPickerOptions = []
    
    let albums = AlbumManager()
    
    override init() {
        
        super.init()
        
        PHPhotoLibrary.shared().register(self)
    }
    
    
    fileprivate var isNotDetermined = false
    func initialLibrary() -> Bool {
        let state = PHPhotoLibrary.authorizationStatus()
        if state == .authorized {
            return true
        } else if state == .notDetermined { // return - ed
            isNotDetermined = true
        }
        return false
    }
    
    open func selectImage(state: PhotoPickerState = .all, viewController: UIViewController, options: PhotoPickerOptions? = nil, finishPickingMediaCallback: (([PhotoPickerManagerMediaItem])->())?) {
        
        switch state {
        case .camera:
            showCamera(viewController: viewController, options: options, finishPickingMediaCallback: finishPickingMediaCallback)
            return
        case .library:
            showLibrary(viewController: viewController, options: options, finishPickingMediaCallback: finishPickingMediaCallback)
            return
        default: break
        }
        
        AlertManager.actionSheet(choosePhotos: viewController, library: {
            self.showLibrary(viewController: viewController, options: options, finishPickingMediaCallback: finishPickingMediaCallback)
        }, camera: {
            self.showCamera(viewController: viewController, options: options, finishPickingMediaCallback: finishPickingMediaCallback)
        })
        
    }
    
    open func selectImage(state: PhotoPickerState = .all, viewController: UIViewController, options: PhotoPickerOptions? = nil, delegate: PhotoPickerManagerDelegate) {
        
        switch state {
        case .camera:
            showCamera(viewController: viewController, options: options, delegate: delegate)
            return
        case .library:
            showLibrary(viewController: viewController, options: options, delegate: delegate)
            return
        default: break
        }
        
        AlertManager.actionSheet(choosePhotos: viewController, library: {
            self.showLibrary(viewController: viewController, options: options, delegate: delegate)
        }, camera: {
            self.showCamera(viewController: viewController, options: options, delegate: delegate)
        })
    }
    
    
    open func showCamera(viewController: UIViewController, options: PhotoPickerOptions? = nil, finishPickingMediaCallback: (([PhotoPickerManagerMediaItem])->())?) {
        clear()
        selectedCallback = finishPickingMediaCallback
        preViewController = viewController
        self.options = options ?? PhotoPickerEmptyOptions
        setCamera()
    }
    
    open func showLibrary(viewController: UIViewController, options: PhotoPickerOptions? = nil, finishPickingMediaCallback: (([PhotoPickerManagerMediaItem])->())?) {
        clear()
        selectedCallback = finishPickingMediaCallback
        preViewController = viewController
        self.options = options ?? PhotoPickerEmptyOptions
        
        setLibrary()
        
    }
    
    open func showCamera(viewController: UIViewController, options: PhotoPickerOptions? = nil,  delegate: PhotoPickerManagerDelegate) {
        clear()
        self.delegate = delegate
        preViewController = viewController
        self.options = options ?? PhotoPickerEmptyOptions
        setCamera()
    }
    
    open func showLibrary(viewController: UIViewController, options: PhotoPickerOptions? = nil, delegate: PhotoPickerManagerDelegate) {
        clear()
        self.delegate = delegate
        preViewController = viewController
        self.options = options ?? PhotoPickerEmptyOptions
        setLibrary()
    }
    
    
    var selectedCallback: (([PhotoPickerManagerMediaItem])->())?
    
    weak public var delegate: PhotoPickerManagerDelegate? = nil
    
    fileprivate(set) var navigationController: PhototPickerNavigationController? {
        didSet {
            if let _ = oldValue?.view.window {
                oldValue?.dismiss(animated: false, completion: nil)
            }
        }
    }
    weak fileprivate(set) var preViewController: UIViewController? = nil
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    public struct InfoKey : Hashable, Equatable, RawRepresentable {
        public private(set) var rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    func clear() {
        navigationController = nil
        selectedCallback = nil
        delegate = nil
        albums.clear()
    }
    
}
/// library
extension PhotoPickerManager {
    
    func setLibrary() {
        
        guard let navigationController = navigationController else {
            if initialLibrary() {
                let albumVC = AlbumListViewController()
                let naviVC = PhototPickerNavigationController(rootViewController: albumVC)
                self.navigationController = naviVC
                if options.displayMode == .recent, let fetch = albumVC.albums.first {
                    self.navigationController?.pushViewController(PhotoListViewController(fetch: fetch), animated: false)
                } else {
                    if albumVC.albums.isEmpty {
                        self.navigationController?.setViewControllers([PhototPickerEmptyViewController(style: .empty)], animated: true)
                    }
                }
            } else {
                let naviVC = PhototPickerNavigationController(rootViewController: PhototPickerEmptyViewController(style: PHPhotoLibrary.authorizationStatus().enableState))
                self.navigationController = naviVC
            }
            
            preViewController?.present(self.navigationController!, animated: true, completion: nil)
            return
        }
        
        if initialLibrary() {
            let albumVC = AlbumListViewController()
            if albumVC.albums.isEmpty {
                navigationController.setViewControllers([PhototPickerEmptyViewController(style: .empty)], animated: true)
            } else {
                if options.displayMode == .list {
                    navigationController.setViewControllers([albumVC], animated: true)
                } else if options.displayMode == .recent, let fetch = albumVC.albums.first {
                    navigationController.setViewControllers([albumVC, PhotoListViewController(fetch: fetch)], animated: true)
                }
            }
        }
        if navigationController.view.window == nil {
            preViewController?.present(navigationController, animated: true, completion: nil)
        }
    }
    
}
/// camera
extension PhotoPickerManager {
    
    func setCamera() {
        
        let navvc: PhototPickerNavigationController =  navigationController ?? PhototPickerNavigationController(rootViewController: UIViewController())
        if UIImagePickerController.isCameraDeviceAvailable(.rear) { // 判断相机是否可用
            let audioAllow = AVCaptureDevice.authorizationStatus(for: .audio)
            let videoAllow = AVCaptureDevice.authorizationStatus(for: .video)
            
            switch videoAllow {
            case .authorized:
                if audioAllow == .authorized {
                    navvc.setViewControllers([CameraViewController(type: self.options.allowFileType)], animated: true)
                } else if audioAllow == .notDetermined {
                    AVCaptureDevice.requestAccess(for: .audio) { allow in
                        DispatchQueue.main.async {
                            self.setCamera()
                        }
                    }
                    return
                } else {
                    navvc.setViewControllers([PhototPickerEmptyViewController(style: .cameraReject)], animated: true)
                }
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { allow in
                    DispatchQueue.main.async {
                        self.setCamera()
                    }
                }
                return
            case .restricted, .denied:
                navvc.setViewControllers([PhototPickerEmptyViewController(style: .cameraReject)], animated: true)
            @unknown default:
                navvc.setViewControllers([PhototPickerEmptyViewController(style: .cameraReject)], animated: true)
            }
        } else {
            navvc.setViewControllers([PhototPickerEmptyViewController(style: .cameraReject)], animated: true)
        }
        
        navigationController = navvc
        preViewController?.present(navigationController!, animated: true, completion: nil)
    }
    
}

extension PhotoPickerManager: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        if PHPhotoLibrary.authorizationStatus() == .authorized && isNotDetermined { // 这里只有 允许之后才会走这个方法
            isNotDetermined = false
            DispatchQueue.main.sync {
                self.setLibrary()
            }
        } else if PHPhotoLibrary.authorizationStatus() == .denied {
            navigationController?.setViewControllers([PhototPickerEmptyViewController(style: .userReject)], animated: true)
        }
    }
    
}

extension PhotoPickerManager.InfoKey {
    
    public static let mediaType: PhotoPickerManager.InfoKey = PhotoPickerManager.InfoKey.init(rawValue: "mediaType") // a PHAssetMediaType
    
    public static let originalImage: PhotoPickerManager.InfoKey = PhotoPickerManager.InfoKey.init(rawValue: "originalImage") // a UIImage
    
    public static let smallImage: PhotoPickerManager.InfoKey = PhotoPickerManager.InfoKey.init(rawValue: "smallImage") // a UIImage
    
    public static let mediaURL: PhotoPickerManager.InfoKey = PhotoPickerManager.InfoKey.init(rawValue: "mediaURL") // an URL
    
    public static let metaData: PhotoPickerManager.InfoKey = PhotoPickerManager.InfoKey.init(rawValue: "metaData") // an imageData
    
    @available(iOS 9.1, *)
    public static let livePhoto: PhotoPickerManager.InfoKey = PhotoPickerManager.InfoKey.init(rawValue: "livePhoto")// a PHLivePhoto
    
    public static let phAsset: PhotoPickerManager.InfoKey = PhotoPickerManager.InfoKey.init(rawValue: "phAsset") // a PHAsset
    
    static let index: PhotoPickerManager.InfoKey = PhotoPickerManager.InfoKey.init(rawValue: "index") // an Int
}
