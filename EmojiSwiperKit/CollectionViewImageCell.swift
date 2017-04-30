//
//  CollectionViewImageCell.swift
//  Emoer
//
//  Created by zz on 26/04/2017.
//  Copyright © 2017 Zhou Wei Ran. All rights reserved.
//

import Foundation

public class CollectionViewImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    public func setImage(_ image: UIImage?) {
        self.imageView.image = image
    }
    
}
