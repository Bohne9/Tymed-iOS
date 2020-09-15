//
//  Supplier.swift
//  Tymed
//
//  Created by Jonah Schueller on 15.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import Foundation


protocol Supplier {
    
    associatedtype T
    associatedtype V
    
    func get(_ value: V?) -> T?
    
}

