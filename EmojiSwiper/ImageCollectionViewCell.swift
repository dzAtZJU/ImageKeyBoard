//
//  ImageCollectionViewCell.swift
//  Emoer
//
//  Created by zz on 14/04/2017.
//  Copyright © 2017 Zhou Wei Ran. All rights reserved.
//

import Foundation
import UIKit
import Photos

internal class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var selectionOrderLabel: UILabel!
    @IBOutlet weak var unicodeEmojiLabel: UILabel!
    
    
    
    internal var selectionOrder: UInt8 {
        get {
            return 0
        }
        set {
            selectionOrderLabel.text = "\(newValue)"
            setSelected(true)
        }
    }
    
    func setImage(_ image: UIImage?) {
        self.imageView.image = image
        self.imageView.isHidden = false
        self.unicodeEmojiLabel.isHidden = true
    }
    
    func setImage(imageData: Data) {
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
    
    func setUnicodeEmoji(emoji: String) {
        self.unicodeEmojiLabel.text = emoji
        self.unicodeEmojiLabel.isHidden = false
        self.imageView.isHidden = true
    }
    
    func setImage(asset: PHAsset) {
        let phImageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        
        phImageManager.requestImage(for: asset, targetSize: bounds.size, contentMode: .aspectFit, options: options, resultHandler: {image, _ in
            self.setImage(image)
            }
        )
    }
    
    func setGifImage(asset: PHAsset) {
        let phImageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        
        phImageManager.requestImageData(for: asset, options: options) { (data, _, _, _) in
                self.setImage(imageData: data!)
        }
    }
    
    func setLabelText(text: String) {
        self.unicodeEmojiLabel.text = text
        self.unicodeEmojiLabel.isHidden = false
        self.imageView.isHidden = true
    }
    
    func setSelected(_ selected: Bool, animated: Bool = false) {
        self.selectionOrderLabel.alpha = selected ? 0.5 : 0.0;
    }
    
}
