//
//  PostTableViewCell.swift
//  CellExchange
//
//  Created by Alexander Hudym on 29.09.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit

protocol PostCellDelegate {
    func nameDidClick(at cell : PostTableViewCell)
    func likeDidClick(at cell : PostTableViewCell)
    func commentDidClick(at cell : PostTableViewCell)
    func shareDidClick(at cell : PostTableViewCell)
}

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
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
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    var delegate : PostCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowOpacity = 0.3
        cellView.layer.shadowRadius = 2.0
        cellView.layer.shadowOffset = CGSize.zero
        
        nameButton.titleLabel?.numberOfLines = 1
        nameButton.addTarget(self, action: #selector(nameDidClick), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(likeDidClick), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(commentDidClick), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareDidClick), for: .touchUpInside)
        
    }
    
    func invalidateSizeForLabels() {
        productLabel.sizeToFit()
        productInfoLabel.sizeToFit()
        productDescriptionLabel.sizeToFit()
    }

    @objc func nameDidClick() {
        delegate?.nameDidClick(at: self)
    }
    
    @objc func likeDidClick() {
        delegate?.likeDidClick(at: self)
    }
    
    @objc func commentDidClick() {
        delegate?.commentDidClick(at: self)
    }
    
    @objc func shareDidClick() {
        delegate?.shareDidClick(at: self)
    }
    
    

}
