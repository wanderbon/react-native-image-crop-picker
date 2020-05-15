//
//  UIWindow.swift
//  ImagePicker
//
//  Created by Alexander Blokhin on 06.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import UIKit

extension UIWindow {
    static var isLandscape: Bool {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows
                .first?
                .windowScene?
                .interfaceOrientation
                .isLandscape ?? false
        } else {
            return UIApplication.shared.statusBarOrientation.isLandscape
        }
    }
}

