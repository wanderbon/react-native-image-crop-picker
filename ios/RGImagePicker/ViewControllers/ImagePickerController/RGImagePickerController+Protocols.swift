//
//  RGImagePickerController+Protocols.swift
//  ImageCropPicker
//
//  Created by Alexander Blokhin on 14.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import Photos

protocol RGImagePickerControllerDelegate : NSObjectProtocol {
    func imagePickerController(_ imagePickerController: RGImagePickerController, didFinishPickingAssets assets: [RGAsset])
    func imagePickerController(_ imagePickerController: RGImagePickerController, shouldSelectAsset asset: PHAsset) -> Bool
    func imagePickerController(_ imagePickerController: RGImagePickerController, didSelectAsset asset: PHAsset)
    func imagePickerController(_ imagePickerController: RGImagePickerController, didDeselectAsset asset: PHAsset)
    func imagePickerControllerDidCancel(_ imagePickerController: RGImagePickerController)
}


extension RGImagePickerControllerDelegate {
    func imagePickerController(_ imagePickerController: RGImagePickerController, didFinishPickingAssets assets: [RGAsset]) {}
    func imagePickerController(_ imagePickerController: RGImagePickerController, shouldSelectAsset asset: PHAsset) -> Bool {
        return true
    }
    func imagePickerController(_ imagePickerController: RGImagePickerController, didSelectAsset asset: PHAsset) {}
    func imagePickerController(_ imagePickerController: RGImagePickerController, didDeselectAsset asset: PHAsset) {}
    func imagePickerControllerDidCancel(_ imagePickerController: RGImagePickerController) {}
}
