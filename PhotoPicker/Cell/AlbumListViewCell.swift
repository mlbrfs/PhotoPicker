//
//  AlbumListViewCell.swift
//  PhotoPicker
//
//  Created by 马磊 on 2019/1/21.
//  Copyright © 2019 MLCode. All rights reserved.
//

import UIKit
import Photos
class AlbumListViewCell: UITableViewCell {
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupUI(){
        self.layoutMargins = UIEdgeInsets.zero
        
        self.accessoryType = .disclosureIndicator
        
        self.contentView.addSubview(coverImage)
        self.contentView.addSubview(photoTitle)
        self.contentView.addSubview(photoNum)
        
        separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        addConstraint(NSLayoutConstraint(item: photoTitle, attribute: .centerY, relatedBy: .equal, toItem: coverImage, attribute: .centerY, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: photoTitle,attribute: .leading, relatedBy: .equal,toItem: coverImage,attribute: .trailing, multiplier: 1.0, constant: 5))
        
        addConstraint(NSLayoutConstraint(item: photoNum,attribute: .centerY,relatedBy: .equal,toItem: coverImage,attribute: .centerY,multiplier: 1.0,constant: 0))
        addConstraint(NSLayoutConstraint(item: photoNum,attribute: .leading,relatedBy: .equal,toItem: photoTitle,attribute: .trailing,multiplier: 1.0,constant: 5))
    }
    
    var asset: PHAsset! {
        didSet {
            let new = asset
            let size = CGSize(width: PhotoPreviewWH, height: PhotoPreviewWH)
            PHCachingImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: nil, resultHandler: { (img, _) in
                if new?.localIdentifier == self.asset.localIdentifier {
                    self.coverImage.image = img
                }
            })
        }
    }
    
    var albumTitleAndCount: (String?, Int)? {
        willSet {
            if newValue == nil {
                return
            }
            self.photoTitle.text = (newValue!.0 ?? "")
            self.photoNum.text = "(\(String(describing: newValue!.1)))"
        }
    }
    
    private lazy var coverImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        return iv
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageWH = min(80, frame.size.height)
        
        coverImage.frame = CGRect(x: 0, y: 0, width: imageWH, height: imageWH)
    }
    
    let photoTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    let photoNum: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        return label
    }()
}
