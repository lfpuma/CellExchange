//
//  ColorExtention.swift
//  CellExchange
//
//  Created by Alexander Hudym on 29.09.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit


extension UIColor {
    
    convenience init(hexaString: String, alpha: CGFloat = 1.0) {
        let chars = Array(hexaString.characters)
        self.init(red:   CGFloat(strtoul(String(chars[1...2]),nil,16))/255,
                  green: CGFloat(strtoul(String(chars[3...4]),nil,16))/255,
                  blue:  CGFloat(strtoul(String(chars[5...6]),nil,16))/255,
                  alpha: alpha)}
    
}
