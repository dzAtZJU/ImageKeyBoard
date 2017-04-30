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
}
