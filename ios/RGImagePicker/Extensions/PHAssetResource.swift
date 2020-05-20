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
        if let fileUrl = self.value(forKey: "privateFileURL") as? URL {
            return fileUrl.absoluteString.replacingOccurrences(
                of: "/Adjustments/Adjustments.plist",
                with: "/Adjustments/FullSizeRender.jpg"
            )
        }
        
        return ""
    }
}
