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
    
    public func setImage(imageData: Data?) {
        if let data = imageData {
            self.setImage(UIImage(data: data))
        }
    }
    
    public var image: UIImage {
        return imageView.image!
    }
    
    public func animate(selected: Bool) {
        if selected {
            UIView.animate(withDuration: 0.4, animations: { self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5) })
        }
        else {
            UIView.animate(withDuration: 0.6, animations: { self.transform = CGAffineTransform.identity })
        }
    }
    
}
