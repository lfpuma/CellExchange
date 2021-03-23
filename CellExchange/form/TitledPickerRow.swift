//
//  PickerRow.swift
//  CellExchange
//
//  Created by Alexander Hudym on 19.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit
import Eureka

final class TitledPickerRow : Row<TitledPickerCell>, RowType {
    
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<TitledPickerCell>(nibName: "TitledPickerCell")
        
    }
    
    override func customDidSelect() {
        super.customDidSelect()
    }
    
   
}
