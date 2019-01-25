//
//  PhototPickerNavigationController.swift
//  PhotoPicker
//
//  Created by 马磊 on 2019/1/17.
//  Copyright © 2019 MLCode. All rights reserved.
//

import UIKit

class PhototPickerNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        interactivePopGestureRecognizer?.delegate = self
        
        navigationBar.isTranslucent = true
        
        navigationBar.setBackgroundImage(UIImage.size(width: 1, height: 1).color(PhotoPickerManager.shared.options.barColor).image, for: UIBarMetrics.default)
        navigationBar.backgroundColor = UIColor.clear
        
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: PhotoPickerManager.shared.options.textColor]
        
        navigationBar.barTintColor = PhotoPickerManager.shared.options.textColor
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return PhotoPickerManager.shared.options.statusBarStyle
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if viewControllers.count > 0 {
            /** setting back button */
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.leftButton())
        }
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.rightButton())
        super.pushViewController(viewController, animated: animated)
        setNavigationBarHidden(false, animated: true)
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        
        for vc in viewControllers.enumerated() {
            if vc.offset > 0 {
                vc.element.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.leftButton())
            }
            vc.element.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.rightButton())

        }
        super.setViewControllers(viewControllers, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let vc = super.popViewController(animated: animated)
        setNavigationBarHidden(false, animated: true)
        return vc
    }
    
    fileprivate func leftButton() -> UIButton {
        let button : UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 44))
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -9, bottom: 0, right: 9)
        button.tintColor = PhotoPickerManager.shared.options.textColor
        button.setImage(UIImage.bundleImage(named: "backItemImage")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(leftBackButtonClick), for: .touchUpInside)
        
        return button
    }
    @objc fileprivate func leftBackButtonClick() {
        _ = popViewController(animated: true)
    }
    
    fileprivate func rightButton() -> UIButton {
        let button : UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 44))
        button.setTitleColor(PhotoPickerManager.shared.options.textColor, for: .normal)
        button.setTitle(LocalizableString.cancel, for: .normal)
        button.addTarget(self, action: #selector(rightCancelBackButtonClick), for: .touchUpInside)
        
        return button
    }
    @objc fileprivate func rightCancelBackButtonClick() {
        
        dismiss(animated: true, completion: nil)
        
    }
}

extension PhototPickerNavigationController: UIGestureRecognizerDelegate { }
