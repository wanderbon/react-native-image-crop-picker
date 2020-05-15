//
//  RGTopRoundedView.swift
//  ImageCropPicker
//
//  Created by Alexander Blokhin on 14.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import UIKit

class RGTopRoundedView: UIView {
    var roundedView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tryRoundOff()
    }
    
    func tryRoundOff() {
        if roundedView == nil {
            let roundedView = UIView(frame: self.bounds)
            roundedView.frame.size.height += 10
            roundedView.backgroundColor = .white
            self.backgroundColor = .init(hex: "292F31")
            self.addSubview(roundedView)
            self.roundedView = roundedView
            self.clipsToBounds = true
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tryRoundOff()
        roundedView?.roundCorners([.topLeft, .topRight], radius: 10)
    }
}
