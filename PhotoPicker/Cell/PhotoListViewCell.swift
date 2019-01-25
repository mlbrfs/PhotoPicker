//
//  PhotoListViewCell.swift
//  PhotoPicker
//
//  Created by 马磊 on 2019/1/21.
//  Copyright © 2019 MLCode. All rights reserved.
//

import UIKit
import Photos

class PhotoListViewCell: UICollectionViewCell {
    
    var asset: PHAsset! {
        didSet {
            let albums = PhotoPickerManager.shared.albums
            indicatorButton.isSelected = albums.isSelect(asset)
            if let index = albums.index(of: asset), indicatorButton.isSelected {
                indicatorButton.setImage(PhotoPickerImage.getDigitImage(num: index + 1), for: .selected)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        imageView.addSubview(disableView)

        contentView.addSubview(indicatorButton)
        
        indicatorButton.addTarget(self, action: #selector(indicatorButtonClick(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let imageView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    
    let disableView = UIView().then {
        $0.backgroundColor = UIColor.color(255, 255, 255, 0.6)
        $0.isHidden = true
    }
    
    fileprivate let indicatorButton = IndicatorButton().then {
        $0.backgroundColor = UIColor.clear
        let image = PhotoPickerImage.getImage()
        $0.setImage(image.unselect, for: .normal)
        $0.setImage(image.select, for: .selected)
    }
    
    @objc private func indicatorButtonClick(_ sender: IndicatorButton) {
        
        if !sender.isSelected {
            if !PhotoPickerManager.shared.albums.isAllowAppendPhotos {
                PhotoPickerManager.shared.albums.showDisableAddPhotosAlert()
                return
            }
        }
        
        sender.isSelected = !sender.isSelected
        let albums = PhotoPickerManager.shared.albums
        switch sender.isSelected { //
        case true:
            albums.append(asset)
            if let index = albums.index(of: asset), indicatorButton.isSelected {
                sender.setImage(PhotoPickerImage.getDigitImage(num: index + 1), for: .selected)
            }
        case false:
            albums.delete(asset)
        }
        
        sender.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 10, options: UIView.AnimationOptions.curveEaseIn, animations: {
            sender.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = contentView.bounds
        disableView.frame = imageView.bounds
        
        let btnWH: CGFloat = 30
        switch PhotoPickerManager.shared.options.indicatorPosition {
        case .topRight:
            indicatorButton.frame = CGRect(x: bounds.size.width - btnWH, y: 0, width: btnWH, height: btnWH)
        case .topLeft:
            indicatorButton.frame = CGRect(x: 0, y: 0, width: btnWH, height: btnWH)
        case .bottomRight:
            indicatorButton.frame = CGRect(x: bounds.size.width - btnWH, y: bounds.size.height - btnWH, width: btnWH, height: btnWH)
        case .bottomLeft:
            indicatorButton.frame = CGRect(x: 0, y: bounds.size.height - btnWH, width: btnWH, height: btnWH)
        }
    }
    
}

fileprivate class IndicatorButton: UIButton {
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        
        let imageH: CGFloat = PhotoPickerManager.shared.options.indicatorStyle == .rectangle ? 20 : 25
        let imageW: CGFloat = PhotoPickerManager.shared.options.indicatorStyle == .rectangle ? 60 : 25
        switch PhotoPickerManager.shared.options.indicatorPosition {
        case .topRight:
            return CGRect(x: bounds.size.width - imageW, y: 0, width: imageW, height: imageH)
        case .topLeft:
            return CGRect(x: 0, y: 0, width: imageW, height: imageH)
        case .bottomRight:
            return CGRect(x: bounds.size.width - imageW, y: bounds.size.height - imageH, width: imageW, height: imageH)
        case .bottomLeft:
            return CGRect(x: 0, y: bounds.size.height - imageH, width: imageW, height: imageH)
        }
        
    }
    
}
