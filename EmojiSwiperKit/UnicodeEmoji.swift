//
//  UnicodeEmoji.swift
//  EmojiSwiper
//
//  Created by zz on 07/05/2017.
//  Copyright © 2017 Zhou Wei Ran. All rights reserved.
//

import Foundation

public class UnicodeEmoji {
    var code: String
    
    init(code: String) {
        self.code = code
    }
    
    var description: String? {
        return code.applyingTransform(.toUnicodeName, reverse: false)
    }
}
