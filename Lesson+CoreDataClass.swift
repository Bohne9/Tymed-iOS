//
//  Lesson+CoreDataClass.swift
//  Tymed
//
//  Created by Jonah Schueller on 15.05.20.
//  Copyright © 2020 Jonah Schueller. All rights reserved.
//
//

import Foundation
import CoreData


public class Lesson: NSManagedObject {

    /// A date object from where the next lesson dates can be computed
    var anchorDate = Date()
    
}
