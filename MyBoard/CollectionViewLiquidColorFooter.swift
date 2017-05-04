//
//  CollectionViewLiquidColorFooter.swift
//  EmojiSwiper
//
//  Created by zz on 05/05/2017.
//  Copyright © 2017 Zhou Wei Ran. All rights reserved.
//

import UIKit

public class CollectionViewLiquidColorFooter: UICollectionReusableView {
    @IBOutlet weak var colorView: UIView!
    
    public func animate(highlight: Bool) {
        
        let alpha = CGFloat(highlight ? 1 : 0.5)
        colorView.backgroundColor = colorView.backgroundColor?.withAlphaComponent(alpha)
    }
}
