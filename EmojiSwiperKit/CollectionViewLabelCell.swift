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
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.3)
        }
        else {
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.15)
        }
    }
}
