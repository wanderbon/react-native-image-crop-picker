//
//  RGAlbumsViewController+PhotoObserver.swift
//  ImagePicker
//
//  Created by Alexander Blokhin on 07.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import Photos

// MARK: - PHPhotoLibraryChangeObserver

extension RGAlbumsViewController: PHPhotoLibraryChangeObserver {
    func reloadIfFirstTime() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if self.authorizationStatus != .authorized && status == .authorized {
            self.authorizationStatus = .authorized
            self.fetchAlbums()
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
            
            return true
        }
        return false
    }
    
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        if !reloadIfFirstTime() {
            DispatchQueue.main.async {
                var fetchResults = self.fetchResults.map { $0.copy() as! PHFetchResult<PHAssetCollection>}
                
                for (index, fetchResult) in self.fetchResults.enumerated() {
                    if let changeDetails = changeInstance.changeDetails(for: fetchResult) {
                        fetchResults[index] = changeDetails.fetchResultAfterChanges
                    }
                }
                
                if (!self.fetchResults.elementsEqual(fetchResults)) {
                    self.fetchResults = fetchResults
                    
                    // Reload albums
                    self.updateAssetCollections()
                    self.tableView?.reloadData()
                }
            }
        }
    }
}
