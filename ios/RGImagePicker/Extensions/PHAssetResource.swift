//
//  PHAssetResource.swift
//  ImageCropPicker
//
//  Created by Alexander Blokhin on 13.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import Photos

extension PHAssetResource {
    var fileURL: String {
        let regex = try! NSRegularExpression(pattern: "(?<=fileURL: ).*(?=\\s)")
        if let result = regex.firstMatch(
            in: debugDescription,
            options: [],
            range: NSRange(location: 0, length: debugDescription.count)) {
            if let range = Range(result.range, in: debugDescription) {
                return String(debugDescription[range])
            }
        }
        return ""
    }
}
