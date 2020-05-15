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
let ERROR_CROPPER_CANCEL_KEY = "E_PICKER_CANCELLED"
let ERROR_CROPPER_CANCEL_MSG = "User cancelled image cropping"


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
    
    var imageForCropping: UIImage?
    var resolve: RCTPromiseResolveBlock?
    var reject: RCTPromiseRejectBlock?
    
    @objc(openPicker:resolver:rejecter:)
    func openPicker(options: NSDictionary,
                    resolver resolve: @escaping RCTPromiseResolveBlock,
                    rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        
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
        
        self.imageForCropping = image
        
        DispatchQueue.main.async {
            let cropViewController = CropViewController(image: image)
            
            cropViewController.delegate = self
            cropViewController.modalPresentationStyle = .fullScreen
            
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

// MARK: - RGImagePickerControllerDelegate

extension ImageCropPicker: RGImagePickerControllerDelegate {
    func imagePickerController(_ imagePickerController: RGImagePickerController, didFinishPickingAssets assets: [RGAsset]) {
        self.resolve?(assets.map { (asset) -> [String : Any] in
            return asset.toDictionary()
        })
    }
}

// MARK: - CropViewControllerDelegate

extension ImageCropPicker: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {        
        if let imageForCropping = self.imageForCropping,
            imageForCropping.size != image.size {
            
            self.reject = nil
            
            let filePath = RGTmpFilesHelper.generateTmpJPGPath()
            let fileUrl = URL(fileURLWithPath: filePath)
            
            try? image
                .jpegData(compressionQuality: 0.9)?
                .write(to: fileUrl, options: [.atomic])
            
            let response: [String : Any] = [
                "path" : "file://\(filePath)",
                "width" : Int(cropRect.width),
                "height" : Int(cropRect.height),
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
