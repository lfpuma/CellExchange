//
//  TitledSwitchCell.swift
//  CellExchange
//
//  Created by Alexander Hudym on 19.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit
import Eureka

class TitledSwitchCell : Cell<Bool>, CellType {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var switchView: UISwitch!
    
    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        super.setup()
        height = { 80 }
        switchView.addTarget(self, action: #selector(switchDidChanged), for: .valueChanged)
    }
    
    @objc func switchDidChanged() {
        row.value = switchView.isOn
        row.updateCell()
    }
    
    override func update() {
        titleLabel.text = row.title
        switchView.isOn = row.value ?? false
        if let row = row as? TitledSwitchRow {
            subtitleLabel.text = row.subtitle
        }
    }
    
    deinit {
        
    }
    
}
