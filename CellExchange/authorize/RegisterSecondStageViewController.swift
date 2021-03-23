//
//  RegisterSecondStageViewController.swift
//  CellExchange
//
//  Created by Alexander Hudym on 29.09.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit
import RETableViewManager
import Eureka
import ActionSheetPicker_3_0
import SVProgressHUD
import Alamofire

protocol RegisterSecondStageDelegate {
    func onSuccess()
}

class RegisterSecondStageViewController: FormViewController {
    
    let countries = InfoManager.instance.getCountries()
    var regions = [Region]()
    var freeZones = InfoManager.instance.getFreeZones()
    
    var manager : RETableViewManager!
    var email = ""
    var password = ""
    var selectedCountry = Country()
    var selectedRegion = Region()
    var selectedFreeZone = FreeZone()
    
    var delegate : RegisterSecondStageDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
        tableView.separatorStyle = .none
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.2167961299, green: 0.6839216352, blue: 0.874153614, alpha: 1)
        navigationController?.navigationBar.barStyle = .blackOpaque
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        title = "Register"
        navigationItem.setLeftBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "ic_close"), style: .plain, target: self, action: #selector(closeDidClick)), animated: true)
        
        form +++ Section { section in
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    let headerLabel = UILabel()
                    headerLabel.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                    headerLabel.text = "Fill in this form to complete registration"
                    headerLabel.textAlignment = .center
                    headerLabel.textColor = #colorLiteral(red: 0.7529411765, green: 0.7254901961, blue: 0.7254901961, alpha: 1)
                    headerLabel.font = .systemFont(ofSize: 13.0)
                    return headerLabel
                }))
                header.height = {40}
                return header
            } ()
            section.footer = {
                var footer = HeaderFooterView<UIView>(.callback({
                    return UIView()
                }))
                footer.height = {0}
                return footer
            }()
        } <<< TitledTextRow("full_name") { row in
            row.title = "Full name"
        } <<< TitledTextRow("phone_number") { row in
            row.title = "Phone number"
            row.cell.valueTextField.keyboardType = .phonePad
        } <<< TitledPickerRow ("country") { row in
            row.title = "Country"
            row.onCellSelection { cell, row in
                ActionSheetStringPicker.show(withTitle: "Country", rows: self.countries.map {$0.title}, initialSelection: self.countries.index(where: {$0.id == self.selectedCountry.id}) ?? 0, doneBlock: { picker, index, values in
                    self.selectedCountry = self.countries[index]
                    row.value = self.selectedCountry.title
                    row.updateCell()
                    self.regions = InfoManager.instance.getRegions(by: self.selectedCountry.id)
                }, cancel: nil, origin: cell)
            }
        } <<< TitledPickerRow("region") { row in
            row.title = "Region"
            row.onCellSelection { cell, row in
                guard self.regions.count != 0 else { return }
                ActionSheetStringPicker.show(withTitle: "City", rows: self.regions.map{ $0.title }, initialSelection: self.regions.index(where: {$0.id == self.selectedRegion.id}) ?? 0, doneBlock: { picker, index, values in
                    self.selectedRegion = self.regions[index]
                    row.value = self.selectedRegion.title
                    row.updateCell()
                }, cancel: nil, origin: cell)
            }
        } <<< TitledSwitchRow("is_freezone") { row in
            row.subtitle = "Are you freezone Company?"
            row.onChange { row in
//                form.rowBy(tag: "FreeZone")?.hidden
            }
        } <<< TitledPickerRow("free_zone") {
            $0.hidden = .function(["is_freezone"], { form in
                return !((form.rowBy(tag: "is_freezone") as? TitledSwitchRow)?.value ?? false)
            })
            $0.onCellSelection { cell, row in
                
                ActionSheetStringPicker.show(withTitle: "Freezone", rows: self.freeZones.map{ $0.title }, initialSelection: self.freeZones.index(where: {$0.id == self.selectedFreeZone.id}) ?? 0, doneBlock: { picker, index, values in
                    self.selectedFreeZone = self.freeZones[index]
                    row.value = self.selectedFreeZone.title
                    row.updateCell()
                }, cancel: nil, origin: cell)
                
            }
        }
        
        let footer = UIView()
        footer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        footer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 150)
        let signUpButton = UIButton()
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.backgroundColor = #colorLiteral(red: 0.1843137255, green: 0.6196078431, blue: 0.8431372549, alpha: 1)
        signUpButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        signUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        signUpButton.addTarget(self, action: #selector(signUpDidClick), for: .touchUpInside)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        footer.addSubview(signUpButton)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: signUpButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 180),
            NSLayoutConstraint(item: signUpButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: signUpButton, attribute: .centerX, relatedBy: .equal, toItem: footer, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: signUpButton, attribute: .centerY, relatedBy: .equal, toItem: footer, attribute: .centerY, multiplier: 1, constant: 0)
            ])
        tableView.tableFooterView = footer
    }
    
    @objc func signUpDidClick() {
        if let fullNameRow = form.rowBy(tag: "full_name") as? TitledTextRow,
            let phoneRow = form.rowBy(tag: "phone_number") as? TitledTextRow,
            let isFreeZoneRow = form.rowBy(tag: "is_freezone") as? TitledSwitchRow {
            
            guard let fullName = fullNameRow.value, !fullName.isEmpty else {
                showAlert(message: "Full name cannot be blank.")
                return
            }
            
            guard let phone = phoneRow.value, !phone.isEmpty else {
                showAlert(message: "Phone cannot be blank.")
                return
            }
            
            guard selectedCountry.id != 0 else {
                showAlert(message: "Country cannot be blank.")
                return
            }
            
            guard selectedRegion.id != 0 else {
                showAlert(message: "Region cannot be blank.")
                return
            }
            
            let isFreeZone = isFreeZoneRow.value ?? false
            
            if isFreeZone, selectedFreeZone.id == 0 {
                showAlert(message: "Freezone cannot be blank.")
                return
            }
            
            _ = UserManager.instance.signUp(email: email, password: password, fullName: fullName, countryId: selectedCountry.id, regionId: selectedRegion.id, mobile: phone, isFreeZone: isFreeZone, freeZoneId: isFreeZone ?  selectedFreeZone.id : nil)
                .do(onSubscribe: { SVProgressHUD.show() }, onDispose: { SVProgressHUD.dismiss() })
                .subscribe(onNext: { [weak self] user in
                    let signUpSuccessAlert = UIAlertController(title: "Sign Up", message: "Your account created successfully. We have sent you an email, Please follow the instructions in the email to activate your account.", preferredStyle: .alert)
                    signUpSuccessAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        self?.delegate?.onSuccess()
                        self?.navigationController?.dismiss(animated: true, completion: nil)
                    })
                    self?.present(signUpSuccessAlert, animated: true, completion: nil)
                }, onError: { [weak self] error in
                    if let error = error as? Alamofire.AFError, error.responseCode == 409 {
                        self?.showAlert(message: "This user already registered")
                    } else {
                        self?.showAlert(message: "Registration has failed. Try again later")
                    }
                    
                })
        }
    }
    

    @IBAction func closeDidClick(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(title: String? = "Sign Up", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

