//
//  CollectionViewLabelCell.swift
//  EmojiSwiper
//
//  Created by zz on 29/04/2017.
//  Copyright © 2017 Zhou Wei Ran. All rights reserved.
//

import Foundation

public class CollectionViewLabelCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    public func setText(_ text: String?) {
        label.text = text
    }
    
    public func animate(selected: Bool) {
        if selected {
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.6)
        }
        else {
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.2)
        }
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        if let stringSize = label.attributedText?.size() {
            return stringSize
        }
        return size
    }
    
}
