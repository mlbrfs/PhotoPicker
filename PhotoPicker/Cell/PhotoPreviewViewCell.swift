//
//  PhotoPreviewViewCell.swift
//  PhotoPicker
//
//  Created by 马磊 on 2019/1/21.
//  Copyright © 2019 MLCode. All rights reserved.
//

import UIKit
import Photos

class PhotoPreviewViewCell: UICollectionViewCell {
    
    var clickCallback: (()->())?
    
    var asset: PHAsset! {
        didSet {
            
            let imageScale = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
            
            scrollView.zoomScale = 1.0
            resizeImageView(imageScale)
            
        }
    }
    
    let scrollView = UIScrollView().then {
        $0.maximumZoomScale = 2.5
        $0.isMultipleTouchEnabled = true
        $0.scrollsToTop = false
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        $0.backgroundColor = UIColor.clear
//        $0.delaysContentTouches = false // default is YES. if NO, we immediately call
    }
    
    let imageContainerView = UIView().then {
        $0.backgroundColor = UIColor.clear
    }
    
    let imageView = UIImageView().then {
        $0.backgroundColor = UIColor.clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
        scrollView.delegate = self

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTap(ges:)))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTap(ges:)))
        
        doubleTap.numberOfTapsRequired = 2
        singleTap.require(toFail: doubleTap)
        self.addGestureRecognizer(singleTap)
        self.addGestureRecognizer(doubleTap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func singleTap(ges: UIGestureRecognizer) {
        clickCallback?()
    }
    
    @objc private func doubleTap(ges: UIGestureRecognizer) {
        
        if scrollView.zoomScale < 1.5 {
            scrollView.setZoomScale(2.5, animated: true)
        } else {
            scrollView.setZoomScale(1, animated: true)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.frame = contentView.bounds
        resizeImageView(CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight))
    }
    
    func resizeImageView(_ scale: CGFloat) {
        imageContainerView.frame = bounds
        if scale > bounds.size.width / bounds.size.height {
            var height = self.frame.width / scale
            if height < 1 || height.isNaN {
                height = self.frame.height
            }
            imageContainerView.frame.size.height = floor(height)
            imageContainerView.center = CGPoint(x: imageContainerView.center.x, y: self.bounds.height / 2)
        } else {
            imageContainerView.frame.size.height = floor(self.bounds.width / scale)
        }
        
        if imageContainerView.frame.height > self.frame.height && imageContainerView.frame.height - self.frame.height <= 1 {
            var originFrame = self.imageContainerView.frame
            originFrame.size.height = self.frame.height
            imageContainerView.frame = originFrame
        }
        
        scrollView.contentSize = CGSize(width: self.frame.width, height: max(imageContainerView.frame.height, self.frame.height))
        scrollView.scrollRectToVisible(self.bounds, animated: false)
        scrollView.alwaysBounceVertical = imageContainerView.frame.height > self.frame.height
        
        imageView.frame = imageContainerView.bounds
        
    }
    
}

extension PhotoPreviewViewCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageContainerView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        let offsetX = (scrollView.frame.width > scrollView.contentSize.width) ? (scrollView.frame.width - scrollView.contentSize.width) * 0.5 : 0.0
        let offsetY = (scrollView.frame.height > scrollView.contentSize.height) ? (scrollView.frame.height - scrollView.contentSize.height) * 0.5 : 0.0
        imageContainerView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
        
    }
    
}
