//
//  RGCheckmarkView.swift
//  ImagePicker
//
//  Created by Alexander Blokhin on 04.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import UIKit

class RGSlomoIconView: UIView {
    var iconColor: UIColor!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconColor = .white
    }
    
    override func draw(_ rect: CGRect) {
        self.iconColor.setStroke()
        
        let width: CGFloat = 2.2
        let insetRect: CGRect = rect.insetBy(dx: width / 2, dy: width / 2)
        
        // Draw dashed circle
        let circlePath = UIBezierPath(ovalIn: insetRect)
        
        circlePath.lineWidth = width

        let pattern: [CGFloat] = [0.75, 0.75]
        circlePath.setLineDash(pattern, count: 2, phase: 0)
        circlePath.stroke()
    }
}
