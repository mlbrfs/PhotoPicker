//
//  AlbumListViewController.swift
//  PhotoPicker
//
//  Created by 马磊 on 2019/1/17.
//  Copyright © 2019 MLCode. All rights reserved.
//

import UIKit
import Photos

class AlbumListViewController: UITableViewController {
    
    required init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.clear
        view.backgroundColor = UIColor.white
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "所有相册"
    }
    
    var albums: [Fetch] = PhotoPickerManager.shared.albums.loadAlbums() //PhotoPickerManager.shared.albums.loadAlbums()
    
}

extension AlbumListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(AlbumListViewCell.self, forCellReuseIdentifier: "AlbumListViewCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumListViewCell", for: indexPath) as! AlbumListViewCell
        let asset = albums[indexPath.row]
        cell.asset = asset.fetchResult.firstObject
        cell.photoTitle.text = asset.name
        cell.photoNum.text =  "(\(asset.fetchResult.count))"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        navigationController?.pushViewController(PhotoListViewController(fetch: albums[indexPath.row]), animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
}

