//
//  PostsFilterTableViewController.swift
//  CellExchange
//
//  Created by Alexander Hudym on 01.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit

protocol HomeFilterDelegate {
    func countryDidSelect(country: Country)
}

class HomeFilterViewController: UITableViewController {

    var countries = InfoManager.instance.getCountries()
    var selectedCountry = Country()
    
    var delegate : HomeFilterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Filter"
        
        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneDidClick)), animated: true)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        countries.insert(Country(), at: 0)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = countries[indexPath.row].title
        cell.accessoryType = countries[indexPath.row].id == selectedCountry.id ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedCountry = countries[indexPath.row]
        tableView.reloadData()
    }

    @objc func doneDidClick() {
        navigationController?.popViewController(animated: true)
        delegate?.countryDidSelect(country: selectedCountry)
    }

}
