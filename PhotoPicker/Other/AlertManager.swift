//
//  AlertManager.swift
//  PhotoPicker
//
//  Created by 马磊 on 2019/1/23.
//  Copyright © 2019 MLCode. All rights reserved.
//

import Foundation

class AlertManager {
    
    class func actionSheet(choosePhotos viewController: UIViewController, library: (()->())?, camera: (()->())?, cancel: (()->())? = nil) {
        
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let ac1 = UIAlertAction(title: LocalizableString.cancel, style: .cancel) { (action) in
            cancel?()
        }
        let ac2 = UIAlertAction(title: LocalizableString.photoAlbum, style: .default) { (action) in
            library?()
        }
        let ac3 = UIAlertAction(title: LocalizableString.camera, style: .default) { (action) in
            camera?()
        }
        alertVC.addAction(ac1)
        alertVC.addAction(ac2)
        alertVC.addAction(ac3)
        
        viewController.present(alertVC, animated: true, completion: nil)
        
    }
    
    class func alert(allowPhotos viewController: UIViewController, title: String , click: (()->())? = nil) {
        
        let alertVC = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let ac = UIAlertAction(title: LocalizableString.sure, style: .cancel) { (action) in
            click?()
        }
        alertVC.addAction(ac)
        
        viewController.present(alertVC, animated: true, completion: nil)
    }
    
}


class AlertView: UIView {
    
    fileprivate static var loadingView: AlertView? {
        didSet {
            oldValue?.removeFromSuperview()
            
        }
    }
    
    class func show(_ tips: String, inView: UIView) {
        
        let alert = AlertView()
        loadingView = alert
        inView.addSubview(alert)
        alert.textLabel.text = tips
        alert.frame = inView.bounds
        UIView.animate(withDuration: 0.25, animations: {
            alert.backgroundColor = UIColor.color(0, 0, 0, 0.2)
            alert.contentView.alpha = 1
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            alert.dismiss()
        }
    }
    
    class func showLoading(_ loading: String, inView: UIView) {
        
        let alert = AlertView(isLoading: true)
        loadingView = alert
        inView.addSubview(alert)
        alert.textLabel.text = loading
        alert.frame = inView.bounds
        UIView.animate(withDuration: 0.25) {
            alert.backgroundColor = UIColor.color(0, 0, 0, 0.2)
            alert.contentView.alpha = 1
        }
        
    }
    
    class func dismiss() {
        loadingView?.dismiss()
    }
    
    let contentView = UIView().then {
        $0.backgroundColor = UIColor.white
        $0.layer.cornerRadius = 6
    }
    
    let textLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 20)
        $0.textColor = PhotoPickerManager.shared.options.tintColor
        $0.numberOfLines = 2
    }
    
    lazy var loadingView: UIActivityIndicatorView = {
        let loadingView = UIActivityIndicatorView(style: .gray)
        loadingView.hidesWhenStopped = true
        return loadingView
    }()
    
    let isLoading: Bool
    required init(isLoading: Bool = false) {
        self.isLoading = isLoading
        super.init(frame: .zero)
        
        backgroundColor = UIColor.clear
        contentView.alpha = 0
        addSubview(contentView)
        if isLoading {
            contentView.addSubview(loadingView)
            loadingView.startAnimating()
        }
        contentView.addSubview(textLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isLoading {
            contentView.frame = CGRect(x: (bounds.size.width - 180) * 0.5, y: (bounds.size.height - 100) * 0.5, width: 180, height: 60)
            textLabel.frame = CGRect(x: 0, y: 0, width: contentView.bounds.size.width - 40, height: 25)
            textLabel.center = CGPoint(x: contentView.bounds.midX + 40, y: contentView.bounds.midY)
            
            loadingView.frame = CGRect(x: 20, y: (contentView.bounds.size.height - 40) * 0.5, width: 20, height: 40)
        } else {
            contentView.frame = CGRect(x: (bounds.size.width - 220) * 0.5, y: (bounds.size.height - 100) * 0.5, width: 220, height: 60)
            textLabel.textAlignment = .center
            textLabel.frame = contentView.bounds
        }
    }
    
    func dismiss() {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.backgroundColor = UIColor.clear
            self.contentView.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
        
    }
    
}
