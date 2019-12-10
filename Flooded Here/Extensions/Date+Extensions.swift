//
//  Date+Extensions.swift
//  Flooded Here
//
//  Created by Ahmed Afifi on 12/8/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import Foundation


extension Date {
    
    func formatAsString() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
        
    }
    
}
