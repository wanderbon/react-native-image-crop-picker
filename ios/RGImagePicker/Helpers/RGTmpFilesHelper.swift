//
//  RGTmpFilesHelper.swift
//  ImageCropPicker
//
//  Created by Alexander Blokhin on 14.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import Foundation

struct RGTmpFilesHelper {
    static let tmpAssetPrefix = "ImageCropPicker_"
    
    static func generateTmpFilePath() -> String {
        let tmpDirectoryPath = NSTemporaryDirectory()
        let uuid = UUID().uuidString
        let fileName = "\(tmpAssetPrefix)\(uuid)"
        return tmpDirectoryPath.appending(fileName)
    }
    
    static func generateTmpJPGPath() -> String {
        return generateTmpFilePath().appending(".JPG")
    }
    
    static func removeTmpFiles() {
        let tmpDirectoryPath = NSTemporaryDirectory()
        
        if let files = try? FileManager.default.contentsOfDirectory(atPath: tmpDirectoryPath) {
            for file in files {
                if file.contains(tmpAssetPrefix) {
                    try? FileManager.default.removeItem(atPath: tmpDirectoryPath.appending(file))
                }
            }
        }
    }
}
