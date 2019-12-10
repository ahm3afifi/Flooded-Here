//
//  FloodAnnotation.swift
//  Flooded Here
//
//  Created by Ahmed Afifi on 12/9/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class FloodAnotations: MKPointAnnotation {
    
    let flood: Flood
     
    init(_ flood: Flood) {
        self.flood = flood
    }
    
    
}
