//
//  Label.swift
//  Tymed
//
//  Created by Jonah Schueller on 08.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import UIKit

class PaddingLabel: UILabel{
    
    var insets: UIEdgeInsets?
    
    override func drawText(in rect: CGRect) {
        return super.draw(rect.inset(by: insets ?? UIEdgeInsets.zero))
    }
    
}

