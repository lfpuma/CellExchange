//
//  TextCell.swift
//  CellExchange
//
//  Created by Alexander Hudym on 19.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit
import Eureka

public class TitledTextCell : Cell<String>, CellType, UITextFieldDelegate, TextFieldCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!
    
    public var textField: UITextField! {
        return valueTextField
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//
//    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//
//    }
    public override func setup() {
        super.setup()
        valueTextField.autocapitalizationType = .sentences
        valueTextField.autocorrectionType = .default
        valueTextField.keyboardType = .default
        
        valueTextField.delegate = self
        valueTextField.addTarget(self, action: #selector(valueDidChange), for: .editingChanged)
        height = { 80 }
        
    }
    
    override public func update() {
        titleLabel.text = row.title
        
    }
    
    deinit {
        valueTextField.delegate = nil
        valueTextField.removeTarget(self, action: #selector(valueDidChange), for: .editingChanged)
    }
    
    open override func cellCanBecomeFirstResponder() -> Bool {
        return !row.isDisabled && valueTextField?.canBecomeFirstResponder == true
    }
    
    open override func cellBecomeFirstResponder(withDirection: Direction) -> Bool {
        return valueTextField?.becomeFirstResponder() ?? false
    }
    
    open override func cellResignFirstResponder() -> Bool {
        return valueTextField?.resignFirstResponder() ?? true
    }
    
    @objc open func valueDidChange(_ textField : UITextField) {
        row.value = textField.text
    }
    
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        formViewController()?.beginEditing(of: self)
        formViewController()?.textInputDidBeginEditing(textField, cell: self)
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        formViewController()?.endEditing(of: self)
        formViewController()?.textInputDidEndEditing(textField, cell: self)
        
    }
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldReturn(textField, cell: self) ?? true
    }
    
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return formViewController()?.textInput(textField, shouldChangeCharactersInRange:range, replacementString:string, cell: self) ?? true
    }
    
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldBeginEditing(textField, cell: self) ?? true
    }
    
    open func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldClear(textField, cell: self) ?? true
    }
    
    open func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
    }
    
}


