//
//  UIImage.swift
//  ImagePicker
//
//  Created by Alexander Blokhin on 07.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import UIKit

extension UIImage {
    static func placeholderImage(with size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        
        if let context = UIGraphicsGetCurrentContext() {
            let backgroundColor = UIColor(red: (239.0 / 255.0), green: (239.0 / 255.0), blue: (244.0 / 255.0), alpha: 1.0)
            let iconColor = UIColor(red: (179.0 / 255.0), green: (179.0 / 255.0), blue: (182.0 / 255.0), alpha: 1.0)
            
            // Background
            context.setFillColor(backgroundColor.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
            
            // Icon (back)
            let backIconRect = CGRect(x: size.width * (16.0 / 68.0),
                                      y: size.height * (20.0 / 68.0),
                                      width: size.width * (32.0 / 68.0),
                                      height: size.height * (24.0 / 68.0))
            
            context.setFillColor(iconColor.cgColor)
            context.fill(backIconRect)
            
            context.setFillColor(backgroundColor.cgColor)
            context.fill(backIconRect.insetBy(dx: 1.0, dy: 1.0))
            
            // Icon (front)
            let frontIconRect = CGRect(x: size.width * (20.0 / 68.0),
                                       y: size.height * (24.0 / 68.0),
                                       width: size.width * (32.0 / 68.0),
                                       height: size.height * (24.0 / 68.0))
            
            context.setFillColor(backgroundColor.cgColor)
            context.fill(frontIconRect.insetBy(dx: -1.0, dy: -1.0))
            
            context.setFillColor(iconColor.cgColor)
            context.fill(frontIconRect)
            
            context.setFillColor(backgroundColor.cgColor)
            context.fill(frontIconRect.insetBy(dx: 1.0, dy: 1.0))
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
}
