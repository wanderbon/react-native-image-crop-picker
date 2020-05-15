//
//  RGAsset.swift
//  ImageCropPicker
//
//  Created by Alexander Blokhin on 14.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import Photos

struct RGAsset {
    var fileName: String
    var filePath: String
    var width: Int
    var height: Int
    
    static func create(from asset: PHAsset) -> RGAsset {
        let filename = (asset.value(forKey: "filename") as? String) ?? ""
        let ext = filename.split(separator: ".").last ?? ""
        let hash = asset.localIdentifier.split(separator: "/").first ?? ""
        let filepath = "assets-library://asset/asset.\(ext)?id=\(hash)&ext=\(ext)"
        
        return RGAsset(fileName: filename, filePath: filepath, width: asset.pixelWidth, height: asset.pixelHeight)
    }
    
    func toDictionary() -> [String : Any] {
        return [
            "fileName" : fileName,
            "url" : filePath,
            "width" : width,
            "height" : height,
        ]
    }
}
