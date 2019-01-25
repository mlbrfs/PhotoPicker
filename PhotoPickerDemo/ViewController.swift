//
//  ViewController.swift
//  PhotoPickerDemo
//
//  Created by 马磊 on 2019/1/17.
//  Copyright © 2019 MLCode. All rights reserved.
//

import UIKit
import PhotoPicker

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
    }

    var dataSources = items

}

extension ViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSources.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  dataSources[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)

        cell.textLabel?.text = dataSources[indexPath.section].items[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.backgroundColor = UIColor.white
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:
                cell.backgroundColor = UIColor.magenta
            case 1:
                cell.backgroundColor = UIColor.white
            default: break
            }
        default: break
            
        }
        
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSources[section].header
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                PhotoPickerManager.shared.selectImage(viewController: self) { (info) in
                    let originalImages = info.map({
                        return $0[.originalImage] as! UIImage
                    })
                    self.navigationController?.pushViewController(DetailViewController(images: originalImages), animated: true)
                }
            case 1:
                PhotoPickerManager.shared.selectImage(viewController: self, options: [PhotoPickerOptionsItem.allowType(.onlyVideo)]) { (info) in
                    let originalImages = info.map({
                        return $0[.originalImage] as! UIImage
                    })
                    self.navigationController?.pushViewController(DetailViewController(images: originalImages), animated: true)
                }
            case 2:
                PhotoPickerManager.shared.selectImage(viewController: self, options: [PhotoPickerOptionsItem.allowType(.onlyPhoto)]) { (info) in
                    let originalImages = info.map({
                        return $0[.originalImage] as! UIImage
                    })
                    self.navigationController?.pushViewController(DetailViewController(images: originalImages), animated: true)
                }
            default: break
            }
        case 1:
            switch indexPath.row {
            case 0:
                PhotoPickerManager.shared.showLibrary(viewController: self, options: [.barColor(UIColor.magenta)]) { info in
                    let originalImages = info.map({
                        return $0[.originalImage] as! UIImage
                    })
                    self.navigationController?.pushViewController(DetailViewController(images: originalImages), animated: true)
                }
            case 1:
                PhotoPickerManager.shared.showLibrary(viewController: self, options: [
                    .barColor(UIColor.white),
                    .statusBarStyle(.default),
                    .textColor(UIColor.black),
                    .tintColor(UIColor.red)
                ]) { info in
                    let originalImages = info.map({
                        return $0[.originalImage] as! UIImage
                    })
                    self.navigationController?.pushViewController(DetailViewController(images: originalImages), animated: true)
                }
            case 2:
                PhotoPickerManager.shared.showLibrary(viewController: self, options: [.photoIndicatorPosition(.topLeft)]) { info in
                    let originalImages = info.map({
                        return $0[.originalImage] as! UIImage
                    })
                    self.navigationController?.pushViewController(DetailViewController(images: originalImages), animated: true)
                }
            case 3:
                PhotoPickerManager.shared.showLibrary(viewController: self, options: [.photoIndicatorStyle(.triangleFill)]) { info in
                    let originalImages = info.map({
                        return $0[.originalImage] as! UIImage
                    })
                    self.navigationController?.pushViewController(DetailViewController(images: originalImages), animated: true)
                }
            case 4:
                PhotoPickerManager.shared.showLibrary(viewController: self, options: [
                    .photoIndicatorStyle(.rectangle),
                    .photoIndicatorPosition(.bottomRight)
                ]) { info in
                    let originalImages = info.map({
                        return $0[.originalImage] as! UIImage
                    })
                    self.navigationController?.pushViewController(DetailViewController(images: originalImages), animated: true)
                }
            case 5:
                PhotoPickerManager.shared.showLibrary(viewController: self, options: [
                    .optionsAllowed(3),
                ]) { info in
                    let originalImages = info.map({
                        return $0[.originalImage] as! UIImage
                    })
                    self.navigationController?.pushViewController(DetailViewController(images: originalImages), animated: true)
                }
            default: break
            }
        default: break
        }
    }
    
}

var items: [(header: String, items: [String])] {
    
    let item_0 = (header: "图片选择", items: [
        "图片+视频选择 (默认)",
        "只视频选择",
        "只图片选择"
        ])
    let item_1 = (header: "相册选择", items: [
        "背景变化(紫色导航)",
        "主题变化(白色导航、红色主题，黑色文字)",
        "图片选择按钮位置变化",
        "图片选择按钮类型变化(左上)",
        "图片选择按钮类型/位置都有变化（长条/右下角）",
        "可选图片数修改为3个"
        ])
    let item_2 = (header: "相机拍照选择", items: [
        "图片+视频选择 (默认)",
        "视频选择",
        "图片选择"
        ])
    return [item_0, item_1, item_2]
    
}
