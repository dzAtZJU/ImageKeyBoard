//
//  EmojiGroupCell.swift
//  Emoer
//
//  Created by zz on 10/04/2017.
//  Copyright © 2017 Zhou Wei Ran. All rights reserved.
//

import Foundation
import UIKit


internal class EmojiGroupCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!

    func setImage(_ image: UIImage?) {
        self.imageView.image = image
        self.imageView.isHidden = false
        self.label.isHidden = true
    }
    
    func setImage(imageData: Data) {
        self.setImage(UIImage(data: imageData))
    }
    
    func setLabelText(text: String) {
        self.label.text = text
        self.label.isHidden = false
        self.imageView.isHidden = true
    }
}
