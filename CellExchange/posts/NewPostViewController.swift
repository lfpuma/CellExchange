//
//  NewPostViewController.swift
//  CellExchange
//
//  Created by Alexander Hudym on 29.09.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit
import Eureka
import ImageRow
import SVProgressHUD

protocol NewPostDelegate {
    func onCreate(new post : Post)
}

class NewPostViewController: FormViewController {
    
    var delegate : NewPostDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New post"
        tableView.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
        
        
        form
            +++ Section("Post type") {
                $0.footer = {
                    var footer = HeaderFooterView<UIView>(.callback({
                        return UIView()
                    }))
                    footer.height = {0}
                    return footer
                } ()
            } <<< PushRow<String>("post_type") {
                $0.title = "I want to"
                $0.options = ["buy", "sell"]
            }
        
        form
            +++ Section("Make & model") {
                $0.footer = {
                    var footer = HeaderFooterView<UIView>(.callback({
                        return UIView()
                    }))
                    footer.height = {0}
                    return footer
                } ()
            } <<< PushRow<Category>("category") {
                $0.title = "Category"
                $0.options = InfoManager.instance.getCategories()
                $0.displayValueFor = { $0?.title }
                $0.onChange {
                    if let makeRow = self.form.rowBy(tag: "make") as? PushRow<Make> {
                        if let category = $0.value {
                            makeRow.options = InfoManager.instance.getMakes(by: category.id)
                        } else {
                            makeRow.options = nil
                        }
                        makeRow.value = nil
                        makeRow.updateCell()
                    }
                    
                }
            } <<< PushRow<Make>("make") {
                $0.title = "Make"
                $0.displayValueFor = { $0?.title }
                $0.onChange {
                    if let modelRow = self.form.rowBy(tag: "model") as? PushRow<PhoneModel> {
                        modelRow.options = $0.value != nil ? InfoManager.instance.getModels(by: $0.value!.id) : nil
                        modelRow.value = nil
                        modelRow.updateCell()
                    }
                }
            } <<< PushRow<PhoneModel>("model") {
                $0.title = "Model"
                $0.displayValueFor = { $0?.title }
            } <<< TextRow("model_number") {
                $0.title = "Model number"
            }
        
        form
            +++ Section("More info") {
                $0.footer = {
                    var footer = HeaderFooterView<UIView>(.callback({
                        return UIView()
                    }))
                    footer.height = {0}
                    return footer
                } ()
            } <<< PushRow<StockType>("stock_type") {
                $0.title = "Stock type"
                $0.displayValueFor = {$0?.title}
                $0.options = InfoManager.instance.getStockTypes()
            } <<< TextRow("color") {
                $0.title = "Color"
            } <<< IntRow("storage_capacity") {
                $0.title = "Storage capacity"
            } <<< PushRow<Condition>("condition") {
                $0.title = "Condition"
                $0.displayValueFor = {$0?.title}
                $0.options = InfoManager.instance.getConditions()
            } <<< PushRow<Specification>("specification") {
                $0.title = "Specification"
                $0.displayValueFor = {$0?.title}
                $0.options = InfoManager.instance.getSpecifications()
            } <<< IntRow("qty") {
                $0.title = "Qty"
            }
        
        form
            +++ Section("Detail") {
                $0.footer = {
                    var footer = HeaderFooterView<UIView>(.callback({
                        return UIView()
                    }))
                    footer.height = {0}
                    return footer
                } ()
            } <<< TextAreaRow("description") {
                $0.title = "Description"
                $0.placeholder = "Description"
            } <<< ImageRow("photo") {
                $0.title = "Add photo"
                $0.sourceTypes = .All
                $0.clearAction = .yes(style: .destructive)
            }
        
        
    
        let footer = UIView()
        footer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        footer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 150)
        let signUpButton = UIButton()
        signUpButton.setTitle("Create", for: .normal)
        signUpButton.backgroundColor = #colorLiteral(red: 0.1843137255, green: 0.6196078431, blue: 0.8431372549, alpha: 1)
        signUpButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        signUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        signUpButton.addTarget(self, action: #selector(createDidClick), for: .touchUpInside)
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
    
    @objc func createDidClick() {
        guard let postTypeRow = form.rowBy(tag: "post_type") as? PushRow<String>, let postTypeValue = postTypeRow.value else {
            showAlert(message: "Post type is not fill")
            return
        }
        guard let categoryRow = form.rowBy(tag: "category") as? PushRow<Category>, let category = categoryRow.value else {
            showAlert(message: "Category is not fill")
            return
        }
        guard let makeRow = form.rowBy(tag: "make") as? PushRow<Make>, let make = makeRow.value else {
            showAlert(message: "Make is not fill")
            return
        }
        guard let modelRow = form.rowBy(tag: "model") as? PushRow<PhoneModel>, let model = modelRow.value else {
            showAlert(message: "Model is not fill")
            return
        }
        guard let stockTypeRow = form.rowBy(tag: "stock_type") as? PushRow<StockType>, let stockType = stockTypeRow.value else {
            showAlert(message: "Stock type is not fill")
            return
        }
        guard let conditionRow = form.rowBy(tag: "condition") as? PushRow<Condition>, let condition = conditionRow.value else {
            showAlert(message: "Condition is not fill")
            return
        }
        guard let specificationRow = form.rowBy(tag: "specification") as? PushRow<Specification>, let specification = specificationRow.value else {
            showAlert(message: "Specification is not fill")
            return
        }
        guard let qtyRow = form.rowBy(tag: "qty") as? IntRow, let qty = qtyRow.value else {
            showAlert(message: "Qty is not fill")
            return
        }
        
        var modelNumber : String?
        var color : String?
        var storageCapacity : Int?
        var description : String?
        var photo : UIImage?
        
        if let modelNumberRow = form.rowBy(tag: "model_number") as? TextRow {
            modelNumber = modelNumberRow.value
        }
        
        if let colorRow = form.rowBy(tag: "color") as? TextRow {
            color = colorRow.value
        }
        
        if let storageCapacityRow = form.rowBy(tag: "storage_capacity") as? IntRow {
            storageCapacity = storageCapacityRow.value
        }
        
        if let descriptionRow = form.rowBy(tag: "description") as? TextAreaRow {
            description = descriptionRow.value
        }
        
        if let photoRow = form.rowBy(tag: "photo") as? ImageRow {
            photo = photoRow.value
        }
        
        _ = PostManager.instance.create(interestedInId: postTypeValue == "sell" ? 1 : 2, categoryId: category.id, makeId: make.id, modelId: model.id, modelNumber: modelNumber, stockTypeId: stockType.id, color: color, storageCapacity: storageCapacity, productConditionId: condition.id, specificationId: specification.id, qty: qty, description: description, photo: photo)
            .do(onSubscribe: { SVProgressHUD.show() }, onDispose: { SVProgressHUD.dismiss() })
            .subscribe(onNext: { [weak self] post in
                self?.delegate?.onCreate(new: post)
                self?.navigationController?.popViewController(animated: true)
            }, onError: { [weak self] error in
                print(error)
                self?.showAlert(message: "Create post failed. Try again later")
            })
    }
    
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "New post", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
}


