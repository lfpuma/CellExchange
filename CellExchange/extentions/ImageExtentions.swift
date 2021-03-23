//
//  ImageExtentions.swift
//  CellExchange
//
//  Created by Alexander Hudym on 15.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit


extension UIImage {
    
    class func searchFieldBackgroundImage(color: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)) -> UIImage? {
        let size = CGSize(width: 29, height:29)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let path = UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: size), cornerRadius: 5.5)
        color.setFill()
        path.fill()
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
}
