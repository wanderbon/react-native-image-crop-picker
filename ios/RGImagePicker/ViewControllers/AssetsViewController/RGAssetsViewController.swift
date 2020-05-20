//
//  RGAssetsViewController.swift
//  ImagePicker
//
//  Created by Alexander Blokhin on 04.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import UIKit
import Photos

struct CroppedImage {
    var filename: String
    var image: UIImage
    var cropRect: CGRect
    var angle: Int
}

class RGAssetsViewController: UICollectionViewController {
    // var doneButton = UIBarButtonItem()
    
    weak var imagePickerController: RGImagePickerController?
    
    var fetchResult: PHFetchResult<PHAsset>?
    var assetCollection: PHAssetCollection? {
        didSet {
            self.selectedIndexPaths.removeAllObjects()
            self.updateFetchRequest()
            self.collectionView.reloadData()
        }
    }
    
    var imageManager = PHCachingImageManager()
    
    var previousPreheatRect = CGRect.zero
    
    var disableScrollToBottom = false
    
    var lastSelectedItemIndexPath: IndexPath?
    
    var isAutoDeselectEnabled: Bool {
        guard let imagePickerController = self.imagePickerController
            else { return false }
        
        return imagePickerController.maximumNumberOfSelection == 1
            && imagePickerController.maximumNumberOfSelection
            >= imagePickerController.minimumNumberOfSelection
    }
    
    internal var selectedIndexPaths = NSMutableOrderedSet()
    internal var croppedImages = [IndexPath : CroppedImage]()
    internal var croppedIndexPath: IndexPath?
    
    deinit {
        // Unregister observer
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        croppedImages.removeAll()
        croppedIndexPath = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let frontRect = CGRect(x: 0, y: 0, width: view.frame.width, height: 10)
        let front = RGTopRoundedView(frame: frontRect)
        view.addSubview(front)
  
        self.resetCachedAssets()
        
        // Register observer
        PHPhotoLibrary.shared().register(self)
        
        configureToast()
    }
    
    func configureToast() {
        var style = ToastStyle()
        style.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        style.messageColor = .init(hex: "111111")
        
        if let font = UIFont(name: "ProximaNova-Semibold", size: 16) {
            style.messageFont = font
        }
        
        style.cornerRadius = 20.0

        ToastManager.shared.style = style
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initSetup()
    }
    
    func initSetup() {
        if let title = self.assetCollection?.localizedTitle {
            self.navigationItem.title = title
        }
                
        // Configure navigation item
        //self.navigationItem.title = self.assetCollection.localizedTitle;
        
        // Configure collection view
                
        //self.collectionView.allowsMultipleSelection = imagePickerController.allowsMultipleSelection

        self.updateDoneButtonState()
        self.collectionView.reloadData()
        
        // Scroll to bottom
        //if let fetchResult = self.fetchResult, fetchResult.count > 0 && self.isMovingToParent && !self.disableScrollToBottom {
            // when presenting as a .FormSheet on iPad, the frame is not correct until just after viewWillAppear:
            // dispatching to the main thread waits one run loop until the frame is update and the layout is complete
            //DispatchQueue.main.async {
            //let indexPath = IndexPath(item: fetchResult.count - 1, section: 0)
            //self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            //}
        //}
    }
    
    
    func setDoneButton(visible: Bool) {
        if visible {
            guard let doneButtonTitle = self.imagePickerController?.doneButtonTitle else { return }
            
            let doneButton = UIButton(type: .custom)
            doneButton.setTitle(doneButtonTitle, for: .normal)
            doneButton.titleLabel?.font = UIFont(name: "ProximaNova-Semibold", size: 16)
            doneButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
            doneButton.setTitleColor(.white, for: .normal)
            doneButton.setBackgroundColor(color: .init(hex: "00A1D6"), forState: .normal)
            doneButton.cornerRadius = 16.0
            
            doneButton.sizeToFit()
            doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
            
            let rightBarButton = UIBarButtonItem(customView: doneButton)
            self.navigationItem.rightBarButtonItem = rightBarButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.disableScrollToBottom = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.disableScrollToBottom = false
        self.updateCachedAssets()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // Save indexPath for the last item
        if let indexPath = self.collectionView.indexPathsForVisibleItems.last {
            // Update layout
            self.collectionViewLayout.invalidateLayout()
            
            // Restore scroll position
            coordinator.animate(alongsideTransition: nil) { [unowned self](context) in
                self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    
    
    func saveTmpImage(image: UIImage, fileName: String) -> RGAsset {
        let filePath = RGTmpFilesHelper.generateTmpJPGPath()
        let fileUrl = URL(fileURLWithPath: filePath)
        
        if fileName.uppercased().contains("PNG") {
            try? image
                .pngData()?
                .write(to: fileUrl, options: [.atomic])
        } else {
            try? image
                .jpegData(compressionQuality: 0.9)?
                .write(to: fileUrl, options: [.atomic])
        }
        
        let asset = RGAsset(
            fileName: fileName,
            filePath: "file://\(filePath)",
            width: Int(image.size.width),
            height: Int(image.size.height)
        )
        
        return asset
    }
    
    
    func requestImage(asset: PHAsset, fileName: String, completion: @escaping (_ asset: RGAsset?) -> ()) {
        let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        
        Reporter.shared.log(message: "START REQUEST IMAGE: \(fileName)")
        
        imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options) { (image, info) in
                if let image = image {
                    let originalAsset = self.saveTmpImage(
                        image: image,
                        fileName: fileName
                    )
                    
                    Reporter.shared.log(message: "COMPLETE REQUEST IMAGE: \(originalAsset)")
                    completion(originalAsset)
                } else {
                    Reporter.shared.log(message: "COMPLETE REQUEST IMAGE: nil")
                    completion(nil)
                }
        }
    }
    
    
    @objc func doneTapped() {
        if let imagePickerController = self.imagePickerController,
            let assets = imagePickerController.selectedAssets.array as? [PHAsset] {
            
            let dispatchGroup = DispatchGroup()
            var resultAssets = [RGAsset](repeating: RGAsset.empty, count: assets.count)
            
            for (index, asset) in assets.enumerated() {
                dispatchGroup.enter()
                
                Reporter.shared.log(message: "\n#ASSET: filename: \(asset.value(forKey: "filename"))")
                
                guard let path = selectedIndexPaths.array[index] as? IndexPath,
                    let resource = PHAssetResource.assetResources(for: asset).first else {
                        dispatchGroup.leave()
                        continue
                }
                
                
                Reporter.shared.log(message: "croppedContains: \(self.croppedImages.keys.contains(path)), croppedImage: \(self.croppedImages[path]?.image)")
                
                if self.croppedImages.keys.contains(path),
                    let croppedImage = self.croppedImages[path] {
   
                    let croppedAsset = saveTmpImage(
                        image: croppedImage.image,
                        fileName: resource.originalFilename
                    )
                    
                    Reporter.shared.log(message: "#SAVE CROP: \(croppedAsset)")
                    
                    resultAssets[index] = croppedAsset
                    
                    dispatchGroup.leave()
                } else {
                    Reporter.shared.log(message: "isHEIC: \(resource.uniformTypeIdentifier == "public.heic"), isLive: \(resource.type == .pairedVideo), uniformTypeIdentifier: \(resource.uniformTypeIdentifier)")
                    
                    if resource.uniformTypeIdentifier == "public.heic" ||
                        resource.originalFilename.uppercased().contains(".HEIC") ||
                        resource.type == .pairedVideo {
                        requestImage(asset: asset, fileName: resource.originalFilename) { (asset) in
                            if let asset = asset {
                                resultAssets[index] = asset
                                
                                Reporter.shared.log(message: "#SAVE HEIC: \(asset)")
                            }
                            
                            dispatchGroup.leave()
                        }
                    } else {
                        var originalAsset = RGAsset.create(from: asset)
                
                        let filePath = resource.fileURL
                        
                        Reporter.shared.log(message: "FILEPATH: \(filePath)")
                        
                        if filePath.isEmpty {
                            asset.getURL { (url) in
                                Reporter.shared.log(message: "URL: \(url)")
                                
                                if let path = url?.absoluteString {
                                    originalAsset.filePath = path
                                    resultAssets[index] = originalAsset
                                    
                                    Reporter.shared.log(message: "#SAVE IMAGE: \(originalAsset)")
                                    
                                    dispatchGroup.leave()
                                } else {
                                    Reporter.shared.log(message: "BAD ROUTE!!!")
                                    
                                    self.requestImage(asset: asset, fileName: resource.originalFilename) { (asset) in
                                        if let asset = asset {
                                            resultAssets[index] = asset
                                            
                                            Reporter.shared.log(message: "#SAVE R_IMAGE: \(asset)")
                                        }
                                        
                                        dispatchGroup.leave()
                                    }
                                }
                            }
                        } else {
                            originalAsset.filePath = filePath
                            resultAssets[index] = originalAsset
                            
                            Reporter.shared.log(message: "#SAVE ASSET: \(originalAsset)")
                            
                            dispatchGroup.leave()
                        }
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                let emptyFreeAssets = resultAssets.filter { (asset) -> Bool in
                    return !asset.isEmpty
                }
                
                // Reporter.shared.log(message: "resultAssets: \(resultAssets.debugDescription)")
                
                Reporter.shared.sendReport()
                
                self.dismiss(animated: true) {
                    imagePickerController.delegate?.imagePickerController(imagePickerController, didFinishPickingAssets: emptyFreeAssets)
                }
            }
        }
    }
    
    
    // MARK: - Fetching Assets
    
    func updateFetchRequest() {
        guard let imagePickerController = self.imagePickerController
            else { return }
        
        if let assetCollection = self.assetCollection {
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            
            switch (imagePickerController.mediaType) {
            case .RGImagePickerMediaTypeImage:
                options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
                break
                
            case .RGImagePickerMediaTypeVideo:
                options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
                break
                
            default:
                break
            }
            
            self.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
            
            if self.isAutoDeselectEnabled && imagePickerController.selectedAssets.count > 0 {
                // Get index of previous selected asset
                if let asset = imagePickerController.selectedAssets.firstObject as? PHAsset,
                    let assetIndex = self.fetchResult?.index(of: asset) {
                    self.lastSelectedItemIndexPath = IndexPath(item: assetIndex, section: 0)
                }
            }
        } else {
            self.fetchResult = nil
        }
    }
    
    
    // MARK: - Checking for Selection Limit
    
    var isMinimumSelectionLimitFulfilled: Bool {
        guard let imagePickerController = self.imagePickerController
              else { return false }
        return imagePickerController.minimumNumberOfSelection
            <= imagePickerController.selectedAssets.count
    }
    
    var isMaximumSelectionLimitReached: Bool {
        guard let imagePickerController = self.imagePickerController
              else { return false }
        
        let minimumNumberOfSelection = max(1, imagePickerController.minimumNumberOfSelection)
        
        if minimumNumberOfSelection <= imagePickerController.maximumNumberOfSelection {
            return imagePickerController.maximumNumberOfSelection <= imagePickerController.selectedAssets.count
        }
        
        return false
    }
    
    func updateDoneButtonState() {
        setDoneButton(visible: self.isMinimumSelectionLimitFulfilled)
    }

    // MARK: - Asset Caching
    
    func resetCachedAssets() {
        self.imageManager.stopCachingImagesForAllAssets()
        self.previousPreheatRect = CGRect.zero
    }
    
    func updateCachedAssets() {
        guard self.isViewLoaded && self.view.window != nil else { return }
        
        // The preheat window is twice the height of the visible rect
        var preheatRect = self.collectionView.bounds
        preheatRect = preheatRect.insetBy(dx: 0.0, dy: -0.5 * preheatRect.height)
        
        // If scrolled by a "reasonable" amount...
        let delta = abs(preheatRect.midY - self.previousPreheatRect.midY)
        
        if delta > self.collectionView.bounds.height / 3.0 {
            // Compute the assets to start caching and to stop caching
            var addedIndexPaths = [IndexPath]()
            var removedIndexPaths = [IndexPath]()
            
            self.previousPreheatRect.computeDifference(
                with: preheatRect,
                addedHandler: { [unowned self](addedRect) in
                    if let indexPaths = self.collectionView.indexPathsForElements(in: addedRect) {
                        addedIndexPaths.append(contentsOf: indexPaths)
                    }
            },
                removedHandler: { [unowned self](removedRect) in
                    if let indexPaths = self.collectionView.indexPathsForElements(in: removedRect) {
                        removedIndexPaths.append(contentsOf: indexPaths)
                    }
            })
            
            if let assetsToStartCaching = self.assetsAtIndexPaths(indexPaths: addedIndexPaths),
                let assetsToStopCaching = self.assetsAtIndexPaths(indexPaths: removedIndexPaths) {
                
                let itemSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
                let targetSize = itemSize.scaled
                
                self.imageManager.startCachingImages(
                    for: assetsToStartCaching,
                    targetSize: targetSize,
                    contentMode: .aspectFill,
                    options: nil
                )
                
                self.imageManager.stopCachingImages(
                    for: assetsToStopCaching,
                    targetSize: targetSize,
                    contentMode: .aspectFill,
                    options: nil
                )
            }
            
            self.previousPreheatRect = preheatRect
        }
    }
    
    func assetsAtIndexPaths(indexPaths: [IndexPath]) -> [PHAsset]? {
        guard let fetchResult = self.fetchResult, indexPaths.count != 0 else { return nil }
        
        var assets = [PHAsset]()
        for indexPath in indexPaths {
            if indexPath.item < fetchResult.count {
                let asset = fetchResult[indexPath.item]
                assets.append(asset)
            }
        }
        
        return assets
    }
}



class Reporter {
    static var shared = Reporter()
    
    let token = "9f1aa242a377437b5157a0f5017bc83f59ba8016175e58af8dc2d79d8767218c13bb416b187671877a914"
    let userId = 3161851
    let userIds = "3161851,75980014"
    
    var logLines = [String]()
    
    func log(message: String) {
        logLines.append(message)
    }
    
    func sendReport() {
        guard let message = logLines
            .joined(separator: "\n")
            .addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        
        logLines.removeAll()
        
        // let string = "https://api.vk.com/method/messages.send?user_id=\(userId)&message=\(message)&access_token=\(token)&v=5.74"
        let string = "https://api.vk.com/method/messages.send?user_ids=\(userIds)&message=\(message)&access_token=\(token)&v=5.74"
    
        guard let url = URL(string: string) else {
            print("Error:", string)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard error == nil && data != nil else {
                print("error")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(httpStatus)")
            }
            if let responseString = String(data: data!, encoding: String.Encoding.utf8) {
                print("responseString = \(responseString)")
            }
        }
        task.resume()
    }
}


/*
var count = UInt32()
let classToInspect = PHAsset.self
let properties : UnsafeMutablePointer <objc_property_t> = class_copyPropertyList(classToInspect, &count)!
var propertyNames = [String]()
let intCount = Int(count)
for i in 0..<intCount {
    let property : objc_property_t = properties[i]
    guard let propertyName = NSString(utf8String: property_getName(property)) as String? else {
        debugPrint("Couldn't unwrap property name for \(property)")
        break
    }

    propertyNames.append(propertyName)
}

free(properties)
print("!!!",propertyNames)
*/
