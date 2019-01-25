//
//  BottomBar.swift
//  PhotoPicker
//
//  Created by 马磊 on 2019/1/18.
//  Copyright © 2019 MLCode. All rights reserved.
//

import UIKit

protocol BottomBarDelegate: class {
    func bottomBar(preview bottomBar: BottomBar)

}
extension BottomBarDelegate {

    func bottomBar(preview bottomBar: BottomBar) { }

}

class BottomBar: UIView {

    weak var delegate: BottomBarDelegate? = nil
    
    static var barHeight: CGFloat {
        return BottomBarHeight
    }
    
    let doneButton = UIButton(type: .custom).then {
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 0.6
        $0.layer.borderColor = PhotoPickerManager.shared.options.textColor.cgColor
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        $0.setTitleColor(PhotoPickerManager.shared.options.textColor, for: .normal)
        $0.setTitleColor(UIColor.lightGray, for: .disabled)
        $0.layer.masksToBounds = true
    }
    let line = UIView().then {
        $0.backgroundColor = UIColor.black
        $0.alpha = 0.18
    }
    
    let previewButton = UIButton().then {
        $0.setTitle(LocalizableString.preview, for: .normal)
        $0.setTitleColor(PhotoPickerManager.shared.options.textColor, for: .normal)
        $0.setTitleColor(UIColor.darkGray, for: .disabled)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        $0.isHidden = true
    }
    
    required init() {
        super.init(frame: .zero)
        
        addSubview(doneButton)
        addSubview(previewButton)
        addSubview(line)
        
        doneButton.addTarget(self, action: #selector(doneClicked), for: .touchUpInside)
        previewButton.addTarget(self, action: #selector(previewClicked), for: .touchUpInside)

        NotificationCenter.default.addObserver(self, selector: #selector(albumDidChange(no:)), name: AlbumManager.albumSelectedFetchDidChanged, object: nil)

        resetAblums()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func doneClicked() {
        
        AlbumManager.getImages(with: PhotoPickerManager.shared.albums.selectedFetch) { (items) in
            
            PhotoPickerManager.shared.selectedCallback?(items)
            PhotoPickerManager.shared.delegate?.photoPickerManager(PhotoPickerManager.shared, didFinishPickingMediaWithInfo: items)
//            if PhotoPickerManager.shared.options.autoDismiss {
            PhotoPickerManager.shared.navigationController?.dismiss(animated: true, completion: nil)
            PhotoPickerManager.shared.clear()
//            }
        }
    }
    
    @objc fileprivate func previewClicked() {
        
        delegate?.bottomBar(preview: self)
        
    }
    
    @objc fileprivate func albumDidChange(no: Notification) {
        
        resetAblums()
    }
    
    func resetAblums() {
        
        let albums = PhotoPickerManager.shared.albums
        doneButton.isEnabled = albums.selectedFetch.count > 0
        previewButton.isEnabled = albums.selectedFetch.count > 0

        doneButton.layer.borderColor = doneButton.isEnabled ? doneButton.titleColor(for: .normal)!.cgColor : doneButton.titleColor(for: .disabled)!.cgColor
        
        
        if albums.selectedFetch.count > 0 {
            doneButton.setTitle("\(LocalizableString.finish)(\(albums.selectedFetch.count))", for: .normal)
        } else {
            doneButton.setTitle(LocalizableString.finish, for: .normal)
        }
        
        let doneBtnW = ((doneButton.currentTitle ?? "") as NSString).boundingRect(with: CGSize(width: 150, height: 20), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil).size.width + 14
        doneButton.frame = CGRect(x: ScreenW - doneBtnW - 25, y: 10, width: doneBtnW, height: 30)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let doneBtnW = ((doneButton.currentTitle ?? "") as NSString).boundingRect(with: CGSize(width: 150, height: 20), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], context: nil).size.width + 14
        doneButton.frame = CGRect(x: frame.size.width - doneBtnW - 25, y: 10, width: doneBtnW, height: 30)
        previewButton.frame = CGRect(x: 18, y: 10, width: 40, height: 30)
        line.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: 0.4)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: AlbumManager.albumSelectedFetchDidChanged, object: nil)
    }
    
    
    
}
