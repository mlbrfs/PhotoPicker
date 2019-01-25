//
//  TopBar.swift
//  PhotoPicker
//
//  Created by 马磊 on 2019/1/21.
//  Copyright © 2019 MLCode. All rights reserved.
//

import UIKit

protocol TopBarDelegate: class {
    func topBar(_ topBar: TopBar, didClickBack sender: UIButton)
    func topBar(_ topBar: TopBar, didClickSelect sender: UIButton)
}

extension TopBarDelegate {
    
    func topBar(_ topBar: TopBar, didClickBack sender: UIButton) {}
    func topBar(_ topBar: TopBar, didClickSelect sender: UIButton) {}
    
}

class TopBar: UIView {
    
    static var barHeight: CGFloat {
        return TopBarHeight
    }
    
    let line = UIView().then {
        $0.backgroundColor = UIColor.black
        $0.alpha = 0.18
    }
    
    required init() {
        super.init(frame: .zero)
        
        addSubview(leftButton)
        addSubview(selectBtn)
        addSubview(line)
        
        leftButton.addTarget(self, action: #selector(leftBackButtonClick(sender:)), for: .touchUpInside)
        selectBtn.addTarget(self, action: #selector(selectedButtonClick(sender:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var delegate: TopBarDelegate? = nil
    
    let leftButton = UIButton().then {
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: -9, bottom: 0, right: 9)
        $0.tintColor = UIColor.white
        $0.setImage(UIImage.bundleImage(named: "backItemImage")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
    }
    
    fileprivate let selectBtn = TopBarSelectedButton().then {
        let image = PhotoPickerImage.getImage(style: PhotoIndicatorStyle.circular)
        $0.setImage(image.unselect, for: .normal)
        $0.setImage(image.select, for: .selected)
    }
    var selectedButon: UIButton {
        return selectBtn as UIButton
    }
    
    @objc private func leftBackButtonClick(sender: UIButton) {
        delegate?.topBar(self, didClickBack: sender)
        
    }
    @objc private func selectedButtonClick(sender: UIButton) {
        delegate?.topBar(self, didClickSelect: sender)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        leftButton.frame = CGRect(x: 20, y: bounds.size.height - 40, width: 30, height: 40)
        selectBtn.frame = CGRect(x: frame.size.width - 54, y: bounds.size.height - 44, width: 44, height: 44)
        
        line.frame = CGRect(x: 0, y: bounds.size.height - 0.4, width: bounds.size.width, height: 0.4)
        
    }
    
}

fileprivate class TopBarSelectedButton: UIButton {
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let imageWH: CGFloat = 30
        return CGRect(x: (frame.size.width - imageWH) * 0.5, y: (frame.size.height - imageWH) * 0.5, width: imageWH, height: imageWH)
    }
    
}
