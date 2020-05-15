//
//  RGAlbumsViewController+DataSource.swift
//  ImagePicker
//
//  Created by Alexander Blokhin on 07.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import Photos

// MARK: - UITableViewDataSource

extension RGAlbumsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.assetCollections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imagePickerController = self.imagePickerController else { return RGAlbumCell() }
        
        let cell = (tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as? RGAlbumCell) ?? RGAlbumCell()
        cell.tag = indexPath.row
        cell.borderWidth = 1.0 / UIScreen.main.scale
        
        // Thumbnail
        let assetCollection = self.assetCollections[indexPath.row]
        let options = PHFetchOptions.create(mediaType: imagePickerController.mediaType)
        let fetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
        let imageManager = PHImageManager.default()
        
        if (fetchResult.count >= 1) {
            imageManager.requestImage(
                for: fetchResult[fetchResult.count - 1],
                targetSize: cell.albumImageView.frame.size.scaled,
                contentMode: .aspectFill,
                options: nil
            ) { (result, info) in
                if (cell.tag == indexPath.row) {
                    cell.albumImageView.image = result
                }
            }
        }
        
        if (fetchResult.count == 0) {
            // Set placeholder image
            let size = cell.albumImageView.frame.size
            let placeholderImage = UIImage.placeholderImage(with: size)
            cell.albumImageView.image = placeholderImage
        }
        
        // Album title
        cell.titleLabel.text = assetCollection.localizedTitle
        
        // Number of photos
        cell.countLabel.text = "\(fetchResult.count)"
        
        return cell
    }
}

