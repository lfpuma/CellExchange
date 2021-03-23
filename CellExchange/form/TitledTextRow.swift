//
//  TextRow.swift
//  CellExchange
//
//  Created by Alexander Hudym on 19.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit
import Eureka


public final class TitledTextRow : Row<TitledTextCell>, RowType, KeyboardReturnHandler {
    
    
    open var keyboardReturnType: KeyboardReturnTypeConfiguration?
    
    
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<TitledTextCell>(nibName: "TitledTextCell")
//        TextRow
    }
    
    
    
    
    
    
    
}
