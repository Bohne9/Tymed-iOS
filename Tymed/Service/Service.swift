//
//  Service.swift
//  Tymed
//
//  Created by Jonah Schueller on 22.08.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//

import Foundation

protocol Service {
    
    associatedtype T: Service
    
    static var shared: T { get set }
    
}
 
