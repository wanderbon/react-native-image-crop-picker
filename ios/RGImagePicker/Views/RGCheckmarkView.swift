//
//  RGCheckmarkView.swift
//  ImagePicker
//
//  Created by Alexander Blokhin on 04.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import UIKit

class RGCheckmarkView: UIView {
    var selectedChanged: ((_ isSelected: Bool) -> ())?
    
    var selectedIndex = 0 {
        didSet {
            backgroundView.backgroundColor = selectedIndex > 0 ? .init(hex: "00A1D6") : .clear
            selectedLabel.text = selectedIndex > 0 ? "\(selectedIndex)" : ""
        }
    }
    
    private var backgroundView = UIView()
    private var selectedLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let checkButtonRect = CGRect(x: 0, y: 0, width: 35, height: 35)
        let checkButton = UIButton(type: .custom)
        checkButton.frame = checkButtonRect
        checkButton.cornerRadius = 0.5 * checkButtonRect.width
        checkButton.setBackgroundColor(color: UIColor.black.withAlphaComponent(0.2), forState: .normal)
        checkButton.setBackgroundColor(color: UIColor.black.withAlphaComponent(0.1), forState: .highlighted)
        checkButton.addTarget(self, action: #selector(checkButtonPressed), for: .touchUpInside)
        
        let backgroundRect = CGRect(x: 2.5, y: 2.5, width: 30, height: 30)
        backgroundView = UIView(frame: backgroundRect)
        backgroundView.layer.cornerRadius = backgroundRect.width / 2
        backgroundView.clipsToBounds = true
        backgroundView.layer.borderWidth = 2.0
        backgroundView.layer.borderColor = UIColor.white.cgColor
        backgroundView.isUserInteractionEnabled = false
        
        selectedLabel = UILabel(frame: backgroundView.bounds)
        selectedLabel.isUserInteractionEnabled = false
        selectedLabel.textColor = .white
        selectedLabel.textAlignment = .center
        selectedLabel.font = UIFont.boldSystemFont(ofSize: 14)
       
        backgroundView.addSubview(selectedLabel)
        
        checkButton.addSubview(backgroundView)
        
        addSubview(checkButton)
    }
    
    @objc func checkButtonPressed() {
        if selectedIndex > 0 {
            selectedIndex = 0
            selectedChanged?(false)
        } else {
            selectedChanged?(true)
        }
    }
}



