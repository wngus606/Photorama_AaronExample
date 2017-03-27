//
//  PhotoCollectionViewCell.swift
//  Photorama
//
//  Created by seo on 2017. 3. 27..
//  Copyright © 2017년 seoju. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    func updateWithImagee(image: UIImage?) {
        if let imageToDisplay = image {
            spinner.stopAnimating()
            imageView.image = imageToDisplay
        } else {
            spinner.startAnimating()
            imageView.image = nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateWithImagee(image: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        updateWithImagee(image: nil)
    }
}
