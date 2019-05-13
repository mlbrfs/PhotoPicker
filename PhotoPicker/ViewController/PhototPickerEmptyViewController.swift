//
//  PhototPickerEmptyViewController.swift
//  PhotoPicker
//
//  Created by 马磊 on 2019/1/17.
//  Copyright © 2019 MLCode. All rights reserved.
//

import UIKit
import Photos
class PhototPickerEmptyViewController: UIViewController {

    enum Style {
        case none
        case userReject
        case waitAuthorization
        case lackOfCompetence
        case empty /// 相册中没有对应内容
        
        case cameraReject
        case cameraDisable
        
        var tipsString: String {
            
            switch self {
            case .empty:
                return LocalizableString.empty
            case .lackOfCompetence, .userReject:
                return LocalizableString.albumReject
            case .waitAuthorization, .none:
                return LocalizableString.waitAuthorization
            case .cameraReject:
                return LocalizableString.cameraReject
            case .cameraDisable:
                return LocalizableString.cameraDisable
            }
        }
        
    }
    
    let style: Style
    required init(style: Style) {
        self.style = style
        super.init(nibName: nil, bundle: nil)
        
        emptyTipsLabel.text = style.tipsString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(emptyImageView)
        view.addSubview(emptyTipsLabel)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
    }
    
    let emptyImageView = UIImageView().then {
        $0.image = UIImage.bundleImage(named: "empty")
        $0.contentMode = .scaleAspectFill
    }
    
    let emptyTipsLabel = UILabel().then {
        $0.textColor = UIColor.gray
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        emptyImageView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        emptyImageView.center.x = view.center.x
        emptyImageView.center.y = view.center.y - 50
        emptyTipsLabel.frame = CGRect(x: 0, y: 0, width: ScreenW - 40, height: 40)
        emptyTipsLabel.center.x = view.center.x
        emptyTipsLabel.center.y = emptyImageView.frame.maxY + 25
    }

}

extension PHAuthorizationStatus {
    
    var enableState: PhototPickerEmptyViewController.Style {
        
        switch self {
        case .authorized:
            return .none
        case .denied:
            return .lackOfCompetence
        case .notDetermined:
            return .waitAuthorization
        case .restricted:
            return .userReject
        default:
            return .cameraReject
        }
        
    }
    
}
