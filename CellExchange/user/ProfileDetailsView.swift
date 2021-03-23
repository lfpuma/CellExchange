//
//  ProfileDetailsView.swift
//  CellExchange
//
//  Created by Alexander Hudym on 15.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit

class ProfileDetailsView: UIView {
    
    @IBOutlet weak var informationContainer: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var wtsLabel: UILabel!
    @IBOutlet weak var wtbLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var businessNameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var countryImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var phoneLabel: UIButton!
    @IBOutlet weak var emailLabel: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        informationContainer.layer.shadowColor = UIColor.black.cgColor
        informationContainer.layer.shadowOpacity = 0.3
        informationContainer.layer.shadowRadius = 10
        informationContainer.layer.shadowOffset = CGSize.zero

        
        
    }
    
}
