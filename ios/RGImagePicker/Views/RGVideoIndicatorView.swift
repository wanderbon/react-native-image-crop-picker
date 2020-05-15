//
//  RGCheckmarkView.swift
//  ImagePicker
//
//  Created by Alexander Blokhin on 04.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import UIKit

class RGVideoIndicatorView: UIView {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var videoIcon: RGVideoIconView!
    @IBOutlet weak var slomoIcon: RGSlomoIconView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.frame.size.width = self.bounds.width * 2
        gradientLayer.colors = [UIColor.darkGray.cgColor, UIColor.clear.cgColor]
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
