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
    
    var emojiView: UIImageView = {
        return UIImageView()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func setupUI() {
        emojiView.frame = bounds
        self.addSubview(emojiView)
    }
    
    func setImage(_ image: UIImage?) {
        self.emojiView.image = image
    }
}
