//
//  ViewExtensions.swift
//  ContactApp
//
//  Created by Aabid Khan on 04/02/21.
//  Copyright © 2021 Aabid Khan. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    
    func addShadow(){
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2
    }
    
}
