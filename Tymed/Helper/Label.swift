//
//  Label.swift
//  Tymed
//
//  Created by Jonah Schueller on 08.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class PaddingLabel: UILabel{
    
    var insets: UIEdgeInsets = .zero

    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
 
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += insets.top + insets.bottom
            contentSize.width += insets.left + insets.right
            return contentSize
        }
    }
}

