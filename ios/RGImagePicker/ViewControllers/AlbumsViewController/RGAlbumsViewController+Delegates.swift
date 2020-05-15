//
//  RGAlbumsViewController+Delegates.swift
//  ImageCropPicker
//
//  Created by Alexander Blokhin on 14.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import UIKit

extension RGAlbumsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let assetsViewController = self.storyboard?
            .instantiateViewController(withIdentifier: "RGAssetsViewController") as? RGAssetsViewController,
            let row = self.tableView?.indexPathForSelectedRow?.row,
            let imagePickerController = self.imagePickerController {
            assetsViewController.imagePickerController = self.imagePickerController
            assetsViewController.assetCollection = self.assetCollections[row]
            imagePickerController.selectedAssets.removeAllObjects()
            self.navigationController?.pushViewController(assetsViewController, animated: true)
        }
    }
}
