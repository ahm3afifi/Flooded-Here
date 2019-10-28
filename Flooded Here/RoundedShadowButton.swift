//
//  RoundedShadowButton.swift
//  Flooded Here
//
//  Created by Ahmed Afifi on 10/27/19.
//  Copyright © 2019 Ahmed Afifi. All rights reserved.
//

import UIKit

class RoundedShadowButton: UIButton {

    override func awakeFromNib() {
        setupView()
    }
    
    func setupView() {
        self.layer.cornerRadius = 15.0
        self.layer.shadowRadius = 10.0
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize.zero
    }

}
