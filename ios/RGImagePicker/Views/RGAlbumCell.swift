//
//  RGAlbumCell.swift
//  ImagePicker
//
//  Created by Alexander Blokhin on 04.05.2020.
//  Copyright © 2020 Rambler. All rights reserved.
//

import UIKit

class RGAlbumCell: UITableViewCell {
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    var borderWidth: CGFloat = 0.0 {
        didSet {
            self.albumImageView.cornerRadius = 3.0
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = Colors.backgroundColor
        titleLabel.textColor = Colors.primaryTextColor
        countLabel.textColor = Colors.subTextColor
        
        setDisclosure(toColour: Colors.subTextColor)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension UITableViewCell {
    func setDisclosure(toColour: UIColor) -> () {
        for view in self.subviews {
            if let disclosure = view as? UIButton {
                if let image = disclosure.backgroundImage(for: .normal) {
                    let colouredImage = image.withRenderingMode(.alwaysTemplate);
                    disclosure.setImage(colouredImage, for: .normal)
                    disclosure.tintColor = toColour
                }
            }
        }
    }
}
//borderRadius: 3,
//width: width * 0.18,
//height: width * 0.18,
