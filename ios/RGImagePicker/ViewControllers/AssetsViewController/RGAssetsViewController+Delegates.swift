//
//  RGAssetsViewController+Delegates.swift
//  ImagePicker
//
//  Created by Alexander Blokhin on 07.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import Photos


extension RGAssetsViewController {
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateCachedAssets()
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? RGAssetCell,
            let asset = self.fetchResult?[indexPath.item], asset.mediaType == .image {
            let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            
            self.imageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: nil) { (image, info) in
                    if let image = image,
                        cell.tag == indexPath.item,
                        image.size == targetSize,
                        let imagePickerController = self.imagePickerController {
                        let cropViewController = CropViewController(image: image)
                        cropViewController.delegate = self
                        cropViewController.doneButtonTitle = imagePickerController.cropperChooseText
                        cropViewController.cancelButtonTitle = imagePickerController.cropperCancelText
                        self.croppedIndexPath = indexPath
                        
                        if let croppedImage = self.croppedImages[indexPath] {
                            cropViewController.imageCropFrame = croppedImage.cropRect
                            cropViewController.angle = croppedImage.angle
                        }
                        
                        self.present(cropViewController, animated: true, completion: nil)
                    }
            }
        } else {
            if selectedIndexPaths.contains(indexPath) {
                assetCellDidDeselectAt(indexPath)
            } else {
                assetCellDidSelectAt(indexPath)
            }
        }
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension RGAssetsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let imagePickerController = self.imagePickerController else {
            return CGSize.zero
        }
        
        let numberOfColumns = UIWindow.isLandscape ?
            imagePickerController.numberOfColumnsInLandscape :
            imagePickerController.numberOfColumnsInPortrait
        
        let width = (self.view.frame.width - 12.0 * (CGFloat(numberOfColumns) - 1.0)) / CGFloat(numberOfColumns)
        
        return CGSize(width: width, height: width)
    }
}


// MARK: - RGAssetCellDelegate

extension RGAssetsViewController: RGAssetCellDelegate {
    func shouldSelectItem(at indexPath: IndexPath) -> Bool {
        /*
        guard let imagePickerController = self.imagePickerController else {
            return !self.isMaximumSelectionLimitReached
        }
        
        if let asset = self.fetchResult?[indexPath.item],
            let delegate = imagePickerController.delegate {
            return delegate.imagePickerController(imagePickerController, shouldSelectAsset: asset) 
        }
        
        if self.isAutoDeselectEnabled {
            return true
        }*/
        
        return !self.isMaximumSelectionLimitReached
    }
    
    func assetCellDidSelectAt(_ indexPath: IndexPath) {
        guard let imagePickerController = self.imagePickerController,
            let asset = self.fetchResult?[indexPath.item],
            shouldSelectItem(at: indexPath) else { return }
        
        let selectedAssets = imagePickerController.selectedAssets
        
        if imagePickerController.allowsMultipleSelection {
            if self.isAutoDeselectEnabled && selectedAssets.count > 0 {
                // Remove previous selected asset from set
                selectedAssets.removeObject(at: 0)
                
                // Deselect previous selected asset
                if let lastSelected = self.lastSelectedItemIndexPath {
                    collectionView.deselectItem(at: lastSelected, animated: false)
                }
            }
            
            // Add asset to set
            selectedAssets.add(asset)
            
            selectedIndexPaths.add(indexPath)
            
            self.lastSelectedItemIndexPath = indexPath
            
            self.updateDoneButtonState()
            
            UIView.performWithoutAnimation { 
                self.collectionView.reloadItems(at: self.selectedIndexPaths.array as! [IndexPath])
            }
        } else {
            imagePickerController.delegate?.imagePickerController(imagePickerController, didFinishPickingAssets: [RGAsset.create(from: asset)])
        }
        
        imagePickerController.delegate?.imagePickerController(imagePickerController, didSelectAsset: asset)
    }
    
    func assetCellDidDeselectAt(_ indexPath: IndexPath) {
        guard let imagePickerController = self.imagePickerController,
            let asset = self.fetchResult?[indexPath.item],
            imagePickerController.allowsMultipleSelection else { return }
        
        let selectedAssets = imagePickerController.selectedAssets
        
        // Remove asset from set
        selectedAssets.remove(asset)
        
        self.lastSelectedItemIndexPath = nil
        self.updateDoneButtonState()
        
        if (imagePickerController.showsNumberOfSelectedAssets) {
            if (selectedAssets.count == 0) {
                // Hide toolbar
                self.navigationController?.setToolbarHidden(true, animated: true)
            }
        }
        
        imagePickerController.delegate?.imagePickerController(imagePickerController, didDeselectAsset: asset)
        
        UIView.performWithoutAnimation {
            self.collectionView.reloadItems(at: self.selectedIndexPaths.array as! [IndexPath])
        }
        
        selectedIndexPaths.remove(indexPath)
    }
}


// MARK: - CropViewControllerDelegate

extension RGAssetsViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        if let indexPath = croppedIndexPath {
            if let asset = self.fetchResult?[indexPath.item],
                let filename = asset.value(forKey: "filename") as? String {
                croppedImages[indexPath] = CroppedImage(filename: filename, image: image, cropRect: cropRect, angle: angle)
                
                if selectedIndexPaths.contains(indexPath) {
                    UIView.performWithoutAnimation {
                        self.collectionView.reloadItems(at: [indexPath])
                    }
                } else {
                    self.assetCellDidSelectAt(indexPath)
                }
            }
        }
    }
}
