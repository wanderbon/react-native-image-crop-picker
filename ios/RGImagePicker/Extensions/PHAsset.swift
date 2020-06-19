//
//  PHAsset.swift
//  ImageCropPicker
//
//  Created by Alexander Blokhin on 18.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import Photos

extension PHAsset {
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)) {
        if self.mediaType == .image {
            //Reporter.shared.log(message: "#MEDIA_TYPE: \(self.mediaType.rawValue)")
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.isNetworkAccessAllowed = true
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return false
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput?.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            //Reporter.shared.log(message: "#MEDIA_TYPE: \(self.mediaType.rawValue)")
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .current
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                
                // Slomo support
                if let asset = asset, asset.isKind(of: AVComposition.self) {
                    if let avComposition = asset as? AVComposition,
                        avComposition.tracks.count > 1,
                        let exporter = AVAssetExportSession(
                            asset: avComposition,
                            presetName: AVAssetExportPresetPassthrough
                        ) {
                        let filePath = RGTmpFilesHelper.generateTmpMOVPath()

                        exporter.outputURL = URL(fileURLWithPath: filePath)
                        exporter.outputFileType = AVFileType.mov
                        
                        exporter.exportAsynchronously {
                            if (exporter.status == .completed) {
                                if let url = exporter.outputURL {
                                    completionHandler(url)
                                }
                            } else {
                                completionHandler(nil)
                            }
                        }
                    }
                } else if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        } else {
            //Reporter.shared.log(message: "BAD MEDIA TYPE")
            completionHandler(nil)
        }
    }
}
