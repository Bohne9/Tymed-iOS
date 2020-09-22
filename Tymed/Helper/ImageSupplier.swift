//
//  ImageSupplier.swift
//  Tymed
//
//  Created by Jonah Schueller on 22.09.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import SwiftUI


class ImageSupplier: Supplier {
    
    static let shared = ImageSupplier()
    
    enum ImageType: String {
        
        case homeEmptyTasks = "HomeEmptyTask"
        
    }
    
    typealias T = String
    
    typealias V = ImageType
    
    func get(_ value: ImageType?) -> String? {
        return value?.rawValue
    }
    
    func get(for value: ImageType) -> String {
        return value.rawValue
    }
}
