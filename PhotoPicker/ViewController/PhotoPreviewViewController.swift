//
//  PhotoPreviewViewController.swift
//  PhotoPicker
//
//  Created by 马磊 on 2019/1/17.
//  Copyright © 2019 MLCode. All rights reserved.
//

import UIKit
import Photos

protocol PhotoPreviewViewControllerDelegate: class {
    func photoPreviewViewController(didChangeAlbum viewController: PhotoPreviewViewController)
}
extension PhotoPreviewViewControllerDelegate {
    func photoPreviewViewController(didChangeAlbum viewController: PhotoPreviewViewController) { }
}

class PhotoPreviewViewController: UIViewController {

    let assets: [PHAsset]
    fileprivate(set) var index: Int
    let ly: UICollectionViewFlowLayout
    required init(assets: [PHAsset], index: Int) {
        self.assets = assets
        
        self.index = assets.count > index ? index : 0
        
        self.ly = UICollectionViewFlowLayout()
        ly.minimumLineSpacing = 0
        ly.minimumInteritemSpacing = 0
        ly.scrollDirection = .horizontal
        super.init(nibName: nil, bundle: nil) // init(collectionViewLayout: ly)
        ly.itemSize = CGSize(width: view.frame.size.width, height: view.frame.size.height)

        collectionView.reloadData()
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var delegate: PhotoPreviewViewControllerDelegate? = nil
    
    let topBar = TopBar().then {
        $0.backgroundColor = UIColor.bar
    }
    let bottomBar = BottomBar().then {
        $0.backgroundColor = UIColor.bar
        $0.doneButton.layer.borderColor = UIColor.white.cgColor
        $0.doneButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    lazy var collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height), collectionViewLayout: ly)
    
    override func loadView() {
        super.loadView()
        automaticallyAdjustsScrollViewInsets = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        
        view.addSubview(bottomBar)
        view.addSubview(topBar)

        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        
        collectionView.isPagingEnabled = true
        
        collectionView.backgroundColor = UIColor.black
        
        topBar.delegate = self
        
        collectionView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(albumDidChanged(no:)), name: AlbumManager.albumSelectedFetchDidChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedRotation), name: UIDevice.orientationDidChangeNotification, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        if assets.count > 0 {
            collectionView.setContentOffset(CGPoint(x: CGFloat(index) * self.view.bounds.width, y: 0), animated: false)
            setCurrent(page: index)
        }
    }
    
    @objc private func albumDidChanged(no: Notification) {

        
        
    }
    @objc private func receivedRotation() {
        
        ly.itemSize = CGSize(width: view.frame.size.width, height: view.frame.size.height)
        collectionView.reloadData()
        
        collectionView.setContentOffset(CGPoint(x: CGFloat(index) * view.frame.size.width, y: 0), animated: false)
        
    }
    
    
    var isHiddenStatusBar: Bool = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    override var prefersStatusBarHidden: Bool {
        return isHiddenStatusBar
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let topBarHeight: CGFloat = TopBar.barHeight
        collectionView.frame = view.bounds
        
        ly.itemSize = CGSize(width: view.frame.size.width, height: view.frame.size.height)
        if isHiddenStatusBar {
            bottomBar.frame = CGRect(x: 0, y: view.frame.size.height, width: view.frame.size.width, height: BottomBar.barHeight)
            topBar.frame = CGRect(x: 0, y: -topBarHeight, width: view.frame.size.width, height: topBarHeight)
        } else {
            bottomBar.frame = CGRect(x: 0, y: view.frame.size.height - BottomBar.barHeight, width: view.frame.size.width, height: BottomBar.barHeight)
            topBar.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: topBarHeight)
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: AlbumManager.albumSelectedFetchDidChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    func showORHideBar() {
        
        if isHiddenStatusBar {
            
            UIView.animate(withDuration: 0.25) {
                self.isHiddenStatusBar = false
                self.topBar.frame.origin.y = 0
                self.bottomBar.frame.origin.y = self.view.bounds.size.height - BottomBar.barHeight
            }
            
        } else {
            
            UIView.animate(withDuration: 0.25) {
                self.isHiddenStatusBar = true
                self.topBar.frame.origin.y = -self.topBar.frame.size.height
                self.bottomBar.frame.origin.y = self.view.bounds.size.height
            }
            
        }
        
    }
    
}

extension PhotoPreviewViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.register(PhotoPreviewViewCell.self, forCellWithReuseIdentifier: "PhotoPreviewViewCell")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoPreviewViewCell", for: indexPath) as! PhotoPreviewViewCell
        let asset = assets[indexPath.item]
        cell.asset = asset
        
        cell.clickCallback = { [weak self] in
            
            self?.showORHideBar()
            
        }
        
        PHCachingImageManager.default().requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: nil) { [cell] image, info in
            if cell.asset.localIdentifier == asset.localIdentifier {
                DispatchQueue.main.async {
                    cell.imageView.image = image
                    cell.layoutIfNeeded()
                }
            }
        }
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        index = Int(collectionView.contentOffset.x / view.frame.size.width)
        setCurrent(page: index)
        
    }
    
    func setCurrent(page: Int) {
        
        let asset = assets[page]
        let albums = PhotoPickerManager.shared.albums
        topBar.selectedButon.isSelected = albums.isSelect(asset)
        if let index = albums.index(of: asset) {
            topBar.selectedButon.setImage(PhotoPickerImage.getDigitImage(num: index + 1), for: .selected)
        }
        
    }
    
}

extension PhotoPreviewViewController: TopBarDelegate {
    
    func topBar(_ topBar: TopBar, didClickBack sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func topBar(_ topBar: TopBar, didClickSelect sender: UIButton) {
        if !sender.isSelected {
            if !PhotoPickerManager.shared.albums.isAllowAppendPhotos {
                PhotoPickerManager.shared.albums.showDisableAddPhotosAlert()
                return
            }
        }
        index = Int(collectionView.contentOffset.x / view.frame.size.width)
        
        sender.isSelected = !sender.isSelected
        let albums = PhotoPickerManager.shared.albums
        if sender.isSelected {
            albums.append(assets[index])
        } else {
            albums.delete(assets[index])
        }
        
        setCurrent(page: index)
        
        sender.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 10, options: UIView.AnimationOptions.curveEaseIn, animations: {
            sender.transform = CGAffineTransform.identity
        }, completion: nil)
        
        delegate?.photoPreviewViewController(didChangeAlbum: self)
    }
    
}
