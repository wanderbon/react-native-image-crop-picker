//
//  RGAlbumsViewController.swift
//  ImagePicker
//
//  Created by Alexander Blokhin on 04.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import UIKit
import Photos

class RGAlbumsViewController: UIViewController {
    weak var imagePickerController: RGImagePickerController?
    
    var fetchResults = [PHFetchResult<PHAssetCollection>]()
    var assetCollections = [PHAssetCollection]()
    
    var authorizationStatus = PHAuthorizationStatus.notDetermined
    
    @IBOutlet weak var tableView: UITableView?
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.delegate = self
        tableView?.dataSource = self
        
        tableView?.backgroundColor = Colors.backgroundColor
        
        view.backgroundColor = Colors.backgroundColor
        
        authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        if (authorizationStatus == .denied) {
            alertMedaAccess()
        } else {
            fetchAlbums()
        }
        
        // Register observer
        PHPhotoLibrary.shared().register(self)
    }
    
    
    func alertMedaAccess() {
        guard let language = Locale.current.languageCode else { return }
        
        let title = language == "ru" ? "Медиа контент недоступен" : "Media Library Unavailable"
        let message = language == "ru" ? "Необходимо разрешить приложению доступ к медиа данным" : "Permission is required to access media data"
        let settings = language == "ru" ? "Настройки" : "Settings"
        let cancel = language == "ru" ? "Отмена" : "Cancel"
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: settings, style: .default) { (_) -> Void in
            let settingsUrl = URL(string: UIApplication.openSettingsURLString)
            if let url = settingsUrl {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        let cancelAction = UIAlertAction(title: cancel, style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    // Fetch user albums and smart albums
    
    func fetchAlbums() {
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        
        self.fetchResults = [smartAlbums, userAlbums]
        
        self.updateAssetCollections()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = self.imagePickerController?.albumsTitle
    }
    
    // MARK: - Actions
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true) {
            if let imagePickerController = self.imagePickerController {
                imagePickerController.delegate?.imagePickerControllerDidCancel(imagePickerController)
            }
        }
    }
    
    
    // MARK: - Fetching Asset Collections
    
    func updateAssetCollections() {
        // Filter albums
        
        guard let imagePickerController = self.imagePickerController else {
            return
        }
        
        if let assetCollectionSubtypes = self.imagePickerController?.assetCollectionSubtypes {
            var smartAlbums = Dictionary <PHAssetCollectionSubtype, [PHAssetCollection]> (minimumCapacity: assetCollectionSubtypes.count)
            var userAlbums = [PHAssetCollection]()
            
            for fetchResult in self.fetchResults {
                fetchResult.enumerateObjects { (assetCollection, index, stop) in
                    let subtype = assetCollection.assetCollectionSubtype
                    if subtype == .albumRegular {
                        userAlbums.append(assetCollection)
                    } else if assetCollectionSubtypes.contains(subtype) {
                        if smartAlbums[subtype] == nil {
                            smartAlbums[subtype] = [PHAssetCollection]()
                        }
                        
                        smartAlbums[subtype]?.append(assetCollection)
                    }
                }
            }
            
            var assetCollections = [PHAssetCollection]()
            let options = PHFetchOptions.create(mediaType: imagePickerController.mediaType)
            options.fetchLimit = 1
            
            // Fetch smart albums
            for assetCollectionSubtype in assetCollectionSubtypes {
                if let collections = smartAlbums[assetCollectionSubtype] {
                    
                    for collection in collections {
                        let assets = PHAsset.fetchAssets(in: collection, options: options)
                        
                        if assets.count > 0 {
                            assetCollections.append(collection)
                        }
                    }
                    
                    // assetCollections.append(contentsOf: collections)
                }
            }
            
            // Fetch user albums
            // assetCollections.append(contentsOf: userAlbums)
            
            for collection in userAlbums {
                let assets = PHAsset.fetchAssets(in: collection, options: options)
                
                if assets.count > 0 {
                    assetCollections.append(collection)
                }
            }
            
            self.assetCollections = assetCollections
        }
    }
    
    // MARK: - Checking for Selection Limit
    
    func isMinimumSelectionLimitFulfilled() -> Bool {
        guard let imagePickerController = self.imagePickerController else { return false }
        return imagePickerController.minimumNumberOfSelection <= imagePickerController.selectedAssets.count
    }

    func isMaximumSelectionLimitReached() -> Bool {
        guard let imagePickerController = self.imagePickerController else { return false }
        let minimumNumberOfSelection = max(1, imagePickerController.minimumNumberOfSelection)
        
        if (minimumNumberOfSelection <= imagePickerController.maximumNumberOfSelection) {
            return imagePickerController.maximumNumberOfSelection <= imagePickerController.selectedAssets.count
        }
        
        return false
    }
}
