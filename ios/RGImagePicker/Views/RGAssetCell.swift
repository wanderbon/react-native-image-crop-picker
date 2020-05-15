//
//  RGAssetCell.swift
//  ImagePicker
//
//  Created by Alexander Blokhin on 04.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import UIKit

protocol RGAssetCellDelegate: NSObjectProtocol {
    func assetCellDidSelectAt(_ indexPath: IndexPath)
    func assetCellDidDeselectAt(_ indexPath: IndexPath)
}

class RGAssetCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var videoIndicatorView: RGVideoIndicatorView!
    @IBOutlet weak var checkmarkView: RGCheckmarkView!
    
    var indexPath: IndexPath? {
        didSet {
            guard let indexPath = self.indexPath, oldValue != indexPath else { return }
            
            checkmarkView.selectedChanged = { [unowned self] isSelected in
                if isSelected {
                    self.delegate?.assetCellDidSelectAt(indexPath)
                } else {
                    self.delegate?.assetCellDidDeselectAt(indexPath)
                }
            }
        }
    }
    
    var selectedIndex: Int = 0 {
        didSet {
            checkmarkView.selectedIndex = selectedIndex
        }
    }
    
    weak var delegate: RGAssetCellDelegate?
    
    var showsOverlayViewWhenSelected: Bool = true
    
    override var isSelected: Bool {
        didSet {
            // self.overlayView.isHidden = !(isSelected && self.showsOverlayViewWhenSelected);
            let opacity: CGFloat = (isSelected && self.showsOverlayViewWhenSelected) ? 0.2 : 0.0
            self.overlayView.backgroundColor = UIColor.white.withAlphaComponent(opacity)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.overlayView.isHidden = false
    }
}
