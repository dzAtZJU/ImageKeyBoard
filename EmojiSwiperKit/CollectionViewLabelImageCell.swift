//
//  CollectionViewLabelImageCell.swift
//  EmojiSwiper
//
//  Created by zz on 08/05/2017.
//  Copyright © 2017 Zhou Wei Ran. All rights reserved.
//

import Foundation

public class CollectionViewLabelImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    public func setImage(_ image: UIImage?) {
        self.imageView.image = image
        imageView.isHidden = false
        label.isHidden = true
    }
    
    public func setText(_ text: String?) {
        label.text = text
        imageView.isHidden = true
        label.isHidden = false
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
            layer.zPosition = 1
            UIView.animate(withDuration: 0.4,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: { self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5) },completion: nil
            )
        }
        else {
            UIView.animate(withDuration: 0.6,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: { self.transform = CGAffineTransform.identity },
                           completion: { _ in self.layer.zPosition = 0 }
            )
        }
    }
}
