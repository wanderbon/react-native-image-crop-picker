//
//  RGAssetsViewController+PhotoLibraryObserver.swift
//  ImagePicker
//
//  Created by Alexander Blokhin on 07.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import Photos

// MARK: - PHPhotoLibraryChangeObserver

extension RGAssetsViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let fetchResult = self.fetchResult else { return }
        
        DispatchQueue.main.async {
            if let collectionChanges = changeInstance.changeDetails(for: fetchResult) {
                // Get the new fetch result
                self.fetchResult = collectionChanges.fetchResultAfterChanges
                
                if !collectionChanges.hasIncrementalChanges || collectionChanges.hasMoves {
                    // We need to reload all if the incremental diffs are not available
                    self.collectionView.reloadData()
                } else {
                    self.collectionView.performBatchUpdates({
                        if let removedIndexes = collectionChanges.removedIndexes, removedIndexes.count > 0 {
                            self.collectionView.deleteItems(at: removedIndexes.indexPathsFromIndexes(with: 0))
                        }
                        
                        if let insertedIndexes = collectionChanges.insertedIndexes, insertedIndexes.count > 0 {
                            self.collectionView.insertItems(at: insertedIndexes.indexPathsFromIndexes(with: 0))
                        }
                        
                        if let changedIndexes = collectionChanges.changedIndexes, changedIndexes.count > 0 {
                            self.collectionView.reloadItems(at: changedIndexes.indexPathsFromIndexes(with: 0))
                        }
                    })
                }
                
                self.resetCachedAssets()
            }
        }
    }
}
