//
//  ImageCropPicker.swift
//  ImageCropPicker
//
//  Created by Alexander Blokhin on 12.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import Foundation
import UIKit
import Photos

let ERROR_PICKER_UNAUTHORIZED_KEY = "E_PERMISSION_MISSING"
let ERROR_PICKER_UNAUTHORIZED_MSG = "Cannot access images. Please allow access if you want to be able to select images."
let ERROR_PICKER_BAD_SIZE_KEY = "BIG_SIZE"
let ERROR_CROPPER_CANCEL_KEY = "E_PICKER_CANCELLED"
let ERROR_CROPPER_CANCEL_MSG = "User cancelled image cropping"
let ERROR_CROPPER_SAME_IMAGE_KEY = "E_CROPPER_ORIGINAL_IMAGE"
let ERROR_CROPPER_SAME_IMAGE_MSG = "User confirm cropping without changing cropping rect"


@objc(ImageCropPicker)
class ImageCropPicker: NSObject {
    @objc static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    func getRootVC() -> UIViewController? {
        var root = UIApplication.shared.delegate?.window??.rootViewController
        
        while (root?.presentedViewController != nil) {
            root = root?.presentedViewController
        }

        return root
    }
    
    var imagePathForCropping: String?
    var imageForCropping: UIImage?
    
    var resolve: RCTPromiseResolveBlock?
    var reject: RCTPromiseRejectBlock?
    
    @objc(openPicker:resolver:rejecter:)
    func openPicker(options: NSDictionary,
                    resolver resolve: @escaping RCTPromiseResolveBlock,
                    rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        
        self.imagePathForCropping = nil
        self.imageForCropping = nil
        
        self.resolve = resolve
        self.reject = reject
        
        PHPhotoLibrary.requestAuthorization { (status) in
            if status != .authorized {
                reject(ERROR_PICKER_UNAUTHORIZED_KEY, ERROR_PICKER_UNAUTHORIZED_MSG, nil)
                return
            }
        }
        
        DispatchQueue.main.async {
            let imagePickerController = RGImagePickerController()
            
            imagePickerController.delegate = self
            
            if let maxFiles = options.object(forKey: "maxFiles") as? Int {
                imagePickerController.maximumNumberOfSelection = maxFiles
            }
            
            if let restrictionMode = options.object(forKey: "restrictionMode") as? Bool {
                imagePickerController.restrictionMode = restrictionMode
            }
            
            if let mediaType = options.object(forKey: "mediaType") as? String {
                if mediaType == "photo" {
                    imagePickerController.mediaType = .RGImagePickerMediaTypeImage
                } else if mediaType == "video" {
                    imagePickerController.mediaType = .RGImagePickerMediaTypeVideo
                }
            }
            
            if let albumsTitle = options.object(forKey: "albumsTitle") as? String {
                imagePickerController.albumsTitle = albumsTitle
            }
            
            if let doneButtonTitle = options.object(forKey: "doneButtonTitle") as? String {
                imagePickerController.doneButtonTitle = doneButtonTitle
            }
            
            if let chooseText = options.object(forKey: "cropperChooseText") as? String {
                imagePickerController.cropperChooseText = chooseText
            }
                
            if let cancelText = options.object(forKey: "cropperCancelText") as? String {
                imagePickerController.cropperCancelText = cancelText
            }
              
            imagePickerController.modalPresentationStyle = .fullScreen
            self.getRootVC()?.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    
    @objc(openCropper:resolver:rejecter:)
    func openCropper(options: NSDictionary,
                    resolver resolve: @escaping RCTPromiseResolveBlock,
                    rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        
        self.resolve = resolve
        self.reject = reject
        
        guard
            let path = options.object(forKey: "path") as? String,
            let url = URL(string: path),
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data)
        else { return }
        
        self.imagePathForCropping = path
        self.imageForCropping = image
        
        DispatchQueue.main.async {
            let cropViewController = CropViewController(image: image)
            
            let squareMode = (options.object(forKey: "squareMode") as? Bool) ?? false
            
            if squareMode {
                cropViewController.aspectRatioLockEnabled = squareMode
                cropViewController.aspectRatioPreset = .presetSquare
                cropViewController.resetAspectRatioEnabled = false
                cropViewController.squareMode = squareMode
            }
            
            cropViewController.delegate = self
            cropViewController.modalPresentationStyle = .fullScreen

            if isGif(path) {
                if let url = URL(string: path) {
                    let fileSize = getRemoteFileSize(url: url)
                    if squareMode && isBadGif(filePath: path, size: image.size, fileSize: UInt64(fileSize)) {
                        self.reject?(ERROR_PICKER_BAD_SIZE_KEY, nil, nil)
                    } else {
                        let response: [String : Any] = [
                            "path" : path,
                            "width" : Int(image.size.width),
                            "height" : Int(image.size.height),
                            "fileName" : "\(UUID().uuidString).GIF"
                        ]
                        
                        self.resolve?(response)
                    }
                    
                    return
                }
            }
            
            if let chooseText = options.object(forKey: "cropperChooseText") as? String {
                cropViewController.doneButtonTitle = chooseText
            }
                
            if let cancelText = options.object(forKey: "cropperCancelText") as? String {
               cropViewController.cancelButtonTitle = cancelText
            }
            
            self.getRootVC()?.present(cropViewController, animated: true, completion: nil)
        }
    }
    
    
    @objc func clean() {
        RGTmpFilesHelper.removeTmpFiles()
    }
}


// MARK: - Helpers
func sizeForLocalFilePath(filePath: String) -> UInt64 {
    do {
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath.replacingOccurrences(of: "file://", with: ""))
        if let fileSize = fileAttributes[FileAttributeKey.size]  {
            return (fileSize as! NSNumber).uint64Value
        } else {
            print("Failed to get a size attribute from path: \(filePath)")
        }
    } catch {
        print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
    }
    return 0
}


func getRemoteFileSize(url: URL) -> Int64 {
    var request = URLRequest(url: url)
    request.httpMethod = "HEAD"
    var result: Int64 = 0
    
    let group = DispatchGroup()
    group.enter()
    
    DispatchQueue.global().async {
        URLSession.shared.dataTask(with: request) {(_, response, _) in
            if let response = response {
                result = response.expectedContentLength
            }
            group.leave()
        }.resume()
    }
    
    group.wait()
    
    return result
}


func isGif(_ filePath: String) -> Bool {
    return filePath.lowercased().contains(".gif")
}

func isBadGif(filePath: String, size: CGSize, fileSize: UInt64) -> Bool {
    return isGif(filePath) && (size.width > 100 || size.height > 100 || (fileSize / 1024) > 100)
}

func isBadGif(asset: RGAsset) -> Bool {
    let fileSize = sizeForLocalFilePath(filePath: asset.filePath)
    let frameSize = CGSize(width: asset.width, height: asset.height)
    return isBadGif(filePath: asset.filePath, size: frameSize, fileSize: fileSize)
}


// MARK: - RGImagePickerControllerDelegate

extension ImageCropPicker: RGImagePickerControllerDelegate {
    func imagePickerController(_ imagePickerController: RGImagePickerController, didFinishPickingAssets assets: [RGAsset]) {
        if imagePickerController.restrictionMode && assets.count > 0 {
            if isBadGif(asset: assets[0]) {
                self.reject?(ERROR_PICKER_BAD_SIZE_KEY, nil, nil)
                return
            }
        }
        
        self.resolve?(assets.map { (asset) -> [String : Any] in
            return asset.toDictionary()
        })
    }
}

// MARK: - CropViewControllerDelegate

extension ImageCropPicker: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {        
        if let imageForCropping = self.imageForCropping,
            (imageForCropping.size != image.size || angle != 0 || cropViewController.squareMode) {
            
            self.reject = nil
            
            let filePath = RGTmpFilesHelper.generateTmpJPGPath()
            let fileUrl = URL(fileURLWithPath: filePath)
            
            try? image
                .jpegData(compressionQuality: 0.8)?
                .write(to: fileUrl, options: [.atomic])
            
            let response: [String : Any] = [
                "path" : "file://\(filePath)",
                "width" : Int(cropRect.width),
                "height" : Int(cropRect.height),
                "fileName" : "\(UUID().uuidString).JPG"
            ]
            
            self.resolve?(response)
        } else if let path = self.imagePathForCropping,
            let image = imageForCropping {

            self.reject = nil
            
            let response: [String : Any] = [
                "path" : path,
                "width" : Int(image.size.width),
                "height" : Int(image.size.height),
                "fileName" : "\(UUID().uuidString).JPG"
            ]
            
            self.resolve?(response)
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true) {
            self.reject?(ERROR_CROPPER_CANCEL_KEY, ERROR_CROPPER_CANCEL_MSG, nil)
        }
    }
}
