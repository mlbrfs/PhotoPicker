//
//  DetailViewController.swift
//  PhotoPickerDemo
//
//  Created by 马磊 on 2019/1/23.
//  Copyright © 2019 MLCode. All rights reserved.
//

import UIKit

class DetailViewController: UICollectionViewController {

    var images: [UIImage]
    init(images: [UIImage]) {
        self.images = images
        
        let ly = UICollectionViewFlowLayout()
        ly.scrollDirection = .vertical
        let itemCount = 4
        let padding: CGFloat = 5
        let itemWH = (UIScreen.main.bounds.size.width - CGFloat(itemCount + 1) * padding) / CGFloat(itemCount)
        ly.itemSize = CGSize(width: itemWH, height: itemWH)
        ly.minimumLineSpacing = padding
        ly.minimumInteritemSpacing = padding
        super.init(collectionViewLayout: ly)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        collectionView.backgroundColor = UIColor.white
        
        collectionView.alwaysBounceVertical = true

       collectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension DetailViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.register(DetailViewCell.self, forCellWithReuseIdentifier: "DetailViewCell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailViewCell", for: indexPath) as! DetailViewCell
        
        cell.imageView.image = images[indexPath.item]
        
        return cell
    }
    
    
    
}

class DetailViewCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
        
    }
    
    
}
