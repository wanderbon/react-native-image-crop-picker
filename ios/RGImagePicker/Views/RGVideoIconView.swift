//
//  RGCheckmarkView.swift
//  ImagePicker
//
//  Created by Alexander Blokhin on 04.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import UIKit

class RGVideoIconView: UIView {
    var iconColor: UIColor!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconColor = .white
    }

    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        self.iconColor.setFill()
        
        // Draw triangle
        let trianglePath = UIBezierPath()
        
        trianglePath.move(to: CGPoint(x: self.bounds.maxX, y: self.bounds.minY))
        trianglePath.addLine(to: CGPoint(x: self.bounds.maxX, y: self.bounds.maxY))
        trianglePath.addLine(to: CGPoint(x: self.bounds.maxX - self.bounds.midY, y: self.bounds.midY))
        
        trianglePath.close()
        trianglePath.fill()
  
        // Draw rounded square
        let squarePath = UIBezierPath(roundedRect: CGRect(x: self.bounds.minX, y: self.bounds.minY, width: self.bounds.width - self.bounds.midY - 1.0, height: self.bounds.height), cornerRadius: 2.0)
        
        squarePath.fill()
    }
}
