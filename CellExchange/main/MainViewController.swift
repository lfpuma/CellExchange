//
//  MainViewController.swift
//  CellExchange
//
//  Created by Alexander Hudym on 15.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit

class MainViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barTintColor = #colorLiteral(red: 0.1843137255, green: 0.6196078431, blue: 0.8431372549, alpha: 1)
        navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        navigationBar.barStyle = .blackOpaque
        navigationBar.isTranslucent = false
        
        
    }


}
