//
//  RGImagePickerController.swift
//  ImagePicker
//
//  Created by Alexander Blokhin on 04.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import UIKit
import Photos

enum RGImagePickerMediaType: Int {
    case RGImagePickerMediaTypeAny = 0
    case RGImagePickerMediaTypeImage
    case RGImagePickerMediaTypeVideo
}

class RGImagePickerController: UIViewController {
    weak var delegate: RGImagePickerControllerDelegate?
    
    private(set) var selectedAssets = NSMutableOrderedSet()
    
    var assetCollectionSubtypes = [
        PHAssetCollectionSubtype.smartAlbumUserLibrary,
        PHAssetCollectionSubtype.albumMyPhotoStream,
        // PHAssetCollectionSubtype.smartAlbumPanoramas,
        PHAssetCollectionSubtype.smartAlbumVideos,
        // PHAssetCollectionSubtype.smartAlbumBursts
    ]
    
    var mediaType = RGImagePickerMediaType.RGImagePickerMediaTypeAny
    
    var allowsMultipleSelection = true
    
    var minimumNumberOfSelection = 1
    
    var maximumNumberOfSelection = 10
    
    var showsNumberOfSelectedAssets = true
    
    var numberOfColumnsInPortrait = 3
    
    var numberOfColumnsInLandscape = 7
    
    var albumsNavigationController = UINavigationController()
    
    var albumsTitle = "Albums"
    var doneButtonTitle = "Save"
    var cropperChooseText = "Done"
    var cropperCancelText = "Cancel"
    
    var assetBundle: Bundle {
        let bundle = Bundle(for: type(of: self))
        
        if let bundlePath = bundle
            .path(forResource: "RGImagePicker", ofType: "bundle"),
            let bundle = Bundle(path: bundlePath) {
            return bundle
        }
        
        return bundle
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.setUpAlbumsViewController()
        
        if let albumsViewController = self.albumsNavigationController.topViewController as? RGAlbumsViewController {
            albumsViewController.imagePickerController = self
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setUpAlbumsViewController() {
        let storyboard = UIStoryboard(name: "RGImagePicker", bundle: self.assetBundle)
        
        let navigationController = storyboard.instantiateViewController(withIdentifier: "RGAlbumsNavigationController") as! UINavigationController
        
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController.navigationBar.shadowImage = UIImage()
        
        self.addChild(navigationController)
        
        navigationController.view.frame = self.view.bounds
        self.view.addSubview(navigationController.view)
        
        navigationController.didMove(toParent: self)
        self.albumsNavigationController = navigationController
    }
}
