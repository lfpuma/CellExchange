//
//  PostDetailsView.swift
//  CellExchange
//
//  Created by Alexander Hudym on 17.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit

protocol PostDetailsViewDelegate {
    func nameDidClick()
    func likeDidClick()
    func shareDidClick()
}

class PostDetailsView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var userInfoLabel: UILabel!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var productInfoLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var interestedInlabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    var delegate : PostDetailsViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        contentView.layer.shadowColor = UIColor.black.cgColor
//        contentView.layer.shadowOpacity = 0.3
//        contentView.layer.shadowRadius = 2.0
//        contentView.layer.shadowOffset = CGSize.zero
        
        nameButton.titleLabel?.numberOfLines = 1
        nameButton.addTarget(self, action: #selector(nameDidClick), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(likeDidClick), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareDidClick), for: .touchUpInside)
        
    }
    
    
    @objc func nameDidClick() {
        delegate?.nameDidClick()
    }
    
    @objc func likeDidClick() {
        delegate?.likeDidClick()
    }
    
    @objc func shareDidClick() {
        delegate?.shareDidClick()
    }
    
}
