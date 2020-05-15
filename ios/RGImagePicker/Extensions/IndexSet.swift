//
//  IndexSet.swift
//  ImagePicker
//
//  Created by Alexander Blokhin on 06.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import Foundation

extension IndexSet {
    func indexPathsFromIndexes(with section: Int) -> [IndexPath] {
        var indexPaths = [IndexPath]()

        self.forEach { (index) in
            indexPaths.append(IndexPath(item: index, section: section))
        }
        
        return indexPaths
    }
}
