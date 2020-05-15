//
//  UICollectionView.swift
//  ImagePicker
//
//  Created by Alexander Blokhin on 06.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import UIKit

extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath]? {
        guard let allLayoutAttributes = self
            .collectionViewLayout
            .layoutAttributesForElements(in: rect),
            allLayoutAttributes.count != 0 else {
                return nil
        }
        
        var indexPaths = [IndexPath]()
        
        for layoutAttributes in allLayoutAttributes {
            let indexPath = layoutAttributes.indexPath
            indexPaths.append(indexPath)
        }
        
        return indexPaths
    }
}
