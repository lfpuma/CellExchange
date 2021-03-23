//
//  TitledSwitchRow.swift
//  CellExchange
//
//  Created by Alexander Hudym on 19.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit
import Eureka

final class TitledSwitchRow : Row<TitledSwitchCell>, RowType {
    
    var subtitle : String?
    
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<TitledSwitchCell>(nibName: "TitledSwitchCell")
        
    }
    
}
