//
//  PhotoListViewController.swift
//  PhotoPicker
//
//  Created by 马磊 on 2019/1/17.
//  Copyright © 2019 MLCode. All rights reserved.
//

import UIKit
import Photos

class PhotoListViewController: UICollectionViewController {
    
    let fetch: Fetch
    required init(fetch: Fetch) {
        self.fetch = fetch
        
        self.ly = UICollectionViewFlowLayout()
        ly.scrollDirection = .vertical
        
        super.init(collectionViewLayout: ly)
        
        navigationItem.title = self.fetch.name
        PHPhotoLibrary.shared().register(self)
        imageManager.stopCachingImagesForAllAssets()
        
        collectionView.addObserver(self, forKeyPath: "contentSize", options: [.old, .new], context: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let imageManager = PHCachingImageManager()
    
    var ly: UICollectionViewFlowLayout
    
    
    let bottomBar = BottomBar().then {
        $0.backgroundColor = PhotoPickerManager.shared.options.barColor
        $0.previewButton.isHidden = false
    }
    
    fileprivate var padding: CGFloat = 5
    fileprivate var itemWH: CGFloat = 0
    override func loadView() {
        super.loadView()
        view.addSubview(collectionView)
        view.addSubview(bottomBar)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.clear
        view.backgroundColor = UIColor.white
     
        bottomBar.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(albumDidReduce(no:)), name: AlbumManager.albumSelectedFetchDidChanged, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    private var isFirst = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isFirst = false
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let screenW = view.frame.size.width
        
        
        
        bottomBar.frame = CGRect(x: 0, y: view.frame.size.height - BottomBar.barHeight, width: view.frame.size.width, height: BottomBar.barHeight)
        
        let number = 4
        itemWH = min((screenW - CGFloat(number + 1) * padding) / CGFloat(number), 150)
        if itemWH == 150 {
            padding = CGFloat(Int(screenW) % Int(itemWH) / (Int(screenW) / Int(itemWH) + 1))
            if padding < 1 { padding += itemWH } // 避免padding太小，看不出间距
        } else {
            padding = 5
        }
        ly.minimumLineSpacing = padding
        ly.minimumInteritemSpacing = padding
        ly.itemSize = CGSize(width: itemWH, height: itemWH)
        collectionView.contentInset = UIEdgeInsets(top: padding, left: padding, bottom: (BottomBar.barHeight - BottomSafeHeight) + padding, right: padding)
    }
    
    @objc private func albumDidReduce(no: Notification) {
        guard let changed = no.userInfo?[AlbumManager.albumSelectedFetchChangedKey] as? String,
            changed == AlbumManager.AlbumSelectedFetchChanged.decrease
            else {
                // 增加了图片
                if !PhotoPickerManager.shared.albums.isAllowAppendPhotos {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        self.collectionView.reloadData()
                    }
                }
                
            return
        }
        
        guard let changeValues = no.userInfo?[AlbumManager.albumSelectedFetchChangedValueKey] as? [PHAsset],
            changeValues.count > 0 else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.collectionView.reloadData()
                }
            return
        }
        
        
        let indexPaths: [IndexPath] = changeValues.map { item -> IndexPath? in
            guard let index = self.fetch.index(asset: item) else {
                return nil
            }
            return IndexPath(item: index, section: 0)
            }.filter({ $0 != nil }) as! [IndexPath]
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.collectionView.reloadItems(at: indexPaths)
        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "contentSize", isFirst else { return }
        if fetch.fetchResult.count == 0 { return }
        collectionView.scrollToItem(at: IndexPath(item: fetch.fetchResult.count - 1, section: 0), at: .bottom, animated: false)
        
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        NotificationCenter.default.removeObserver(self, name: AlbumManager.albumSelectedFetchDidChanged, object: nil)
        collectionView.removeObserver(self, forKeyPath: "contentSize")
        imageManager.stopCachingImagesForAllAssets()
    }
    
}

extension PhotoListViewController: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetch.fetchResult.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.register(PhotoListViewCell.self, forCellWithReuseIdentifier: "PhotoListViewCell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoListViewCell", for: indexPath) as! PhotoListViewCell
        let asset = fetch.fetchResult[indexPath.row]
        cell.asset = asset
        
        cell.disableView.isHidden = PhotoPickerManager.shared.albums.isSelect(asset) ?
            true :
            !(PhotoPickerManager.shared.albums.selectedFetch.count >= PhotoPickerManager.shared.options.optionsAllowed)
        imageManager.requestImage(for: asset, targetSize: CGSize(width: PhotoPreviewWH, height: PhotoPreviewWH), contentMode: .aspectFill, options: nil) { [cell] image, info in
            if cell.asset.localIdentifier == asset.localIdentifier {
                cell.imageView.image = image
                cell.layoutIfNeeded()
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let set = IndexSet(integersIn: Range(NSRange(location: 0, length: fetch.fetchResult.count))!)
        let assets = fetch.fetchResult.objects(at: set)
        let ppvc = PhotoPreviewViewController(assets: assets, index: indexPath.item)
        ppvc.delegate = self
        navigationController?.pushViewController(ppvc, animated: true)
        
    }
    
}

extension PhotoListViewController: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        if let collectionChanges = changeInstance.changeDetails(for: fetch.fetchResult) {
            DispatchQueue.main.async {
                self.fetch.fetchResult = collectionChanges.fetchResultAfterChanges
                if (collectionChanges.hasIncrementalChanges || collectionChanges.hasMoves) {
                    self.collectionView.reloadData()
                }
                self.imageManager.stopCachingImagesForAllAssets()
            }
        }
    }
    
}

extension PhotoListViewController: PhotoPreviewViewControllerDelegate {
    
    func photoPreviewViewController(didChangeAlbum viewController: PhotoPreviewViewController) {
        
        collectionView.reloadData()
        
    }
    
}

extension PhotoListViewController: BottomBarDelegate {
    
    func bottomBar(preview bottomBar: BottomBar) {
        
        let ppvc = PhotoPreviewViewController(assets: PhotoPickerManager.shared.albums.selectedFetch, index: 0)
        ppvc.delegate = self
        navigationController?.pushViewController(ppvc, animated: true)
        
    }
    
}
