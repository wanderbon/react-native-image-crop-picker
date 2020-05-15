//
//  RGAssetsViewController+DataSource.swift
//  ImagePicker
//
//  Created by Alexander Blokhin on 07.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import Photos

// MARK: - UICollectionViewDataSource

extension RGAssetsViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchResult?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let imagePickerController = self.imagePickerController else { return RGAssetCell() }
          
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCell", for: indexPath) as? RGAssetCell ?? RGAssetCell()
        cell.tag = indexPath.item
        cell.indexPath = indexPath
        cell.delegate = self
        cell.showsOverlayViewWhenSelected = imagePickerController.allowsMultipleSelection
        
        if let asset = self.fetchResult?[indexPath.item] {
            let itemSize = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
            let targetSize = itemSize.scaled
            
            let index = imagePickerController.selectedAssets.index(of: asset)
            cell.selectedIndex = index == NSNotFound ? 0 : index + 1
            
            // Image
            if let croppedImage = croppedImages[indexPath] {
                cell.imageView.image = croppedImage.image
            } else {
                self.imageManager.requestImage(
                    for: asset,
                    targetSize: targetSize,
                    contentMode: .aspectFill,
                    options: nil) { (result, info) in
                        if (cell.tag == indexPath.item) {
                            cell.imageView.image = result
                        }
                }
            }
            
            // Video indicator
            if (asset.mediaType == .video) {
                cell.videoIndicatorView.isHidden = false
                
                let minutes = Int(asset.duration / 60.0)
                let seconds = Int(ceil(asset.duration - 60.0 * Double(minutes)))
                
                cell.videoIndicatorView.timeLabel.text = String(format: "%02ld:%02ld", minutes, seconds)
                
                if asset.mediaSubtypes == PHAssetMediaSubtype.videoHighFrameRate {
                    cell.videoIndicatorView.videoIcon.isHidden = true
                    cell.videoIndicatorView.slomoIcon.isHidden = false
                } else {
                    cell.videoIndicatorView.videoIcon.isHidden = false
                    cell.videoIndicatorView.slomoIcon.isHidden = true
                }
            } else {
                cell.videoIndicatorView.isHidden = true
            }
        }
        
        return cell
    }
}
