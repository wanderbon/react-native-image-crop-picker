//
//  PHFetchOptions.swift
//  ImageCropPicker
//
//  Created by Alexander Blokhin on 14.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import Photos

extension PHFetchOptions {
    static func create(mediaType: RGImagePickerMediaType) -> PHFetchOptions {
        let options = PHFetchOptions()
        
        switch (mediaType) {
        case .RGImagePickerMediaTypeImage:
            options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.image.rawValue)
            return options
            
        case .RGImagePickerMediaTypeVideo:
            options.predicate = NSPredicate(format: "mediaType == %ld", PHAssetMediaType.video.rawValue)
            return options
            
        default:
            return options
        }
    }
}
