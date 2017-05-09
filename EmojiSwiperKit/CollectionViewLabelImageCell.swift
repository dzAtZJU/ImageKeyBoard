//
//  CollectionViewLabelImageCell.swift
//  EmojiSwiper
//
//  Created by zz on 08/05/2017.
//  Copyright © 2017 Zhou Wei Ran. All rights reserved.
//

import Foundation
import ImageIO

public class CollectionViewLabelImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    public func setImage(_ image: UIImage?) {
        self.imageView.image = image
        imageView.isHidden = false
        label.isHidden = true
    }
    
    public var image: UIImage? {
        return imageView.image
    }
    
    public var unicodeEmoji: String? {
            return label.text
    }
    
    public func setText(_ text: String?) {
        label.text = text
        imageView.isHidden = true
        label.isHidden = false
    }
    
    public func setImage(imageData: Data?) {
        if let imageData = imageData {
            let source = CGImageSourceCreateWithData(imageData as CFData, nil)!
            let isGIF = source.isAnimatedGIF
            if isGIF {
                let image = UIImage.gifImageWithData(data: imageData as NSData)
                self.setImage(image)
            }
            else {
                self.setImage(UIImage(data: imageData))
            }
        }
    }
    
    public func animate(selected: Bool) {
        if selected {
            layer.zPosition = 1
            UIView.animateKeyframes(withDuration: 1.5, delay: 0, options: [.overrideInheritedOptions], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1, animations: {
                    self.transform = CGAffineTransform(scaleX: 2, y: 2)
                })
                UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1, animations: {
                    self.transform = CGAffineTransform.identity
                })
            }, completion: { (_) in
                self.layer.zPosition = 0
            })
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
