//
//  PickerCell.swift
//  CellExchange
//
//  Created by Alexander Hudym on 19.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit
import Eureka

class TitledPickerCell : Cell<String>, CellType {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueButton: UIButton!
    
    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        super.setup()
        selectionStyle = .none
        height = { 80 }
        valueButton.addTarget(self, action: #selector(btnDidClick), for: .touchUpInside)
    }
    
    override func update() {
        titleLabel.text = row.title
        valueButton.setTitle(row.value, for: .normal)
    }
    
    deinit {
        valueButton.removeTarget(self, action: #selector(btnDidClick), for: .touchUpInside)
    }
    
    @objc func btnDidClick() {
        row.didSelect()
        row.updateCell()
    }
    
}
