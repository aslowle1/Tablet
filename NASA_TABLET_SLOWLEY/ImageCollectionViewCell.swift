//
//  ImageCollectionViewCell.swift
//  NASA_TABLET_SLOWLEY
//
//  Created by Andros Slowley on 1/22/20.
//  Copyright © 2020 CoPassinjers. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nasaImageView: UIImageView! {
        didSet {
            nasaImageView.clipsToBounds = true
            nasaImageView.layer.masksToBounds = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        nasaImageView.image = nil
    }
}
