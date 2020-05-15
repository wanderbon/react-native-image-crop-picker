//
//  CGSize.swift
//  ImagePicker
//
//  Created by Alexander Blokhin on 06.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import CoreGraphics
import UIKit

extension CGSize {
    func scale(_ scale: CGFloat) -> CGSize {
        return CGSize(width: self.width * scale, height: self.height * scale)
    }
    
    var scaled: CGSize {
        return self.scale(UIScreen.main.scale)
    }
}
