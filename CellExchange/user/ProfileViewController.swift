//
//  ProfileViewController.swift
//  CellExchange
//
//  Created by Alexander Hudym on 29.09.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit
import RxSwift
import AlamofireImage
import MessageUI

class ProfileViewController: PostsViewController {

    var userId = UserManager.instance.currentUserId
    
    var profileDetailsView : ProfileDetailsView!
    
    var currentPage = 1
    var isLoadMoreShow = false
    var isLoadMoreEnabled = true
    
    private var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileDetailsView = UINib(nibName: "ProfileDetailsView", bundle: Bundle.main)
            .instantiate(withOwner: self, options: nil)
            .first as! ProfileDetailsView
        
        title = "Profile"
        
        refreshDidRequest()
        
        if userId == UserManager.instance.currentUserId {
            navigationItem.setRightBarButton(UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(menuDidClick)), animated: true)
        }
        
        
        profileDetailsView.phoneLabel.isUserInteractionEnabled = true
        profileDetailsView.phoneLabel.addTarget(self, action: #selector(phoneDidClick), for: .touchUpInside)
        profileDetailsView.emailLabel.isUserInteractionEnabled = true
        profileDetailsView.emailLabel.addTarget(self, action: #selector(emailDidClick), for: .touchUpInside)
    }
    
    @objc func phoneDidClick() {
        if let url = URL(string: "tel://\(user.mobile)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func emailDidClick() {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([user.email])
        present(mailComposerVC, animated: true, completion: nil)
    }
    
    @objc func menuDidClick() {
        let alertController = UIAlertController(title: "Menu", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Logout", style: .default) { _ in
            UserManager.instance.logout()
            if let loginViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "login") as? LoginViewController {
                self.navigationController?.dismiss(animated: true, completion: nil)
                UIApplication.topViewController()?.present(loginViewController, animated: true, completion: nil)
            }
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    override func refreshDidRequest() {
        currentPage = 1
        isLoadMoreEnabled = true
        _ = Observable.combineLatest(UserManager.instance.getUser(by: userId),
                                     PostManager.instance.getPosts(userId: userId, page: currentPage, perPage: 25)) { ($0, $1) }
            .debounce(0.5, scheduler: MainScheduler.instance)
            .do(onSubscribe: {[weak self] in self?.beginRefreshing()}, onDispose: { [weak self] in self?.endRefreshing()})
            .subscribe(onNext: { [weak self] user, posts in
                if let vc = self {
                    vc.user = user
                    if vc.tableView.tableHeaderView == nil {
                        vc.tableView.tableHeaderView = vc.profileDetailsView
                    }
                    vc.profileDetailsView.frame.size.width = vc.view.frame.width
                    vc.profileDetailsView.layoutIfNeeded()
                    if let coverUrl = URL(string: user.cover) {
                        vc.profileDetailsView.coverImageView.af_setImage(withURL: coverUrl)
                    }
                    if let avatarUrl = URL(string: user.photo) {
                        vc.profileDetailsView.avatarImageView.af_setImage(withURL: avatarUrl, placeholderImage: #imageLiteral(resourceName: "ic_no_avatar_profile"), filter: AspectScaledToFillSizeCircleFilter(size: vc.profileDetailsView.avatarImageView.frame.size))
                    } else {
                        vc.profileDetailsView.avatarImageView.image = #imageLiteral(resourceName: "ic_no_avatar_list")
                    }
                    vc.profileDetailsView.fullNameLabel.text = user.fullName
                    vc.profileDetailsView.businessNameLabel.text = user.registeredTradingName
                    if let country = user.country, let countryImageUrl = URL(string: country.image) {
                        vc.profileDetailsView.countryImageView.af_setImage(withURL: countryImageUrl)
                    }
                    vc.profileDetailsView.roleLabel.text = user.userInfo
                    vc.profileDetailsView.infoLabel.text = user.businessProfile
                    vc.profileDetailsView.phoneLabel.setTitle(user.mobile, for: .normal)
                    vc.profileDetailsView.emailLabel.setTitle(user.email, for: .normal)
                    vc.invalidateHeader()
                    vc.posts = posts
                    vc.tableView.reloadData()
                    vc.currentPage += 1
                }
                }, onError: { print($0) })
    }
    
    
    
    func invalidateHeader() {
        if tableView.tableHeaderView != nil {
            let size = profileDetailsView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
            if size.height != profileDetailsView.frame.height {
                profileDetailsView.frame.size = size
                tableView.tableHeaderView = profileDetailsView
                tableView.layoutIfNeeded()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        invalidateHeader()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rowIndex = indexPath.row
        if isLoadMoreEnabled, !isLoadMoreShow, posts.count >= 5, rowIndex + 5 >= posts.count {
            _ = PostManager.instance.getPosts(userId: userId, page: currentPage, perPage: 25)
                .do(
                    onSubscribe: { [weak self] in
                        if let vc = self {
                            vc.isLoadMoreShow = true
                            let footer = UIView()
                            footer.frame = CGRect(x: 0, y: 0, width: vc.tableView.frame.width, height: 50)
                            let activityIndicator = UIActivityIndicatorView()
                            activityIndicator.activityIndicatorViewStyle = .gray
                            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
                            footer.addSubview(activityIndicator)
                            NSLayoutConstraint.activate([
                                NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: footer, attribute: .centerY, multiplier: 1, constant: 0),
                                NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: footer, attribute: .centerX, multiplier: 1, constant: 0),
                                NSLayoutConstraint(item: activityIndicator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 50),
                                NSLayoutConstraint(item: activityIndicator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 50)
                                ])
                            vc.tableView.tableFooterView = footer
                            activityIndicator.startAnimating()
                        }
                    },
                    onDispose: { [weak self] in
                        self?.isLoadMoreShow = false
                        self?.tableView.tableFooterView = nil
                    }
                )
                .subscribe(
                    onNext: { [weak self] posts in
                        if let vc = self {
                            vc.currentPage += 1
                            vc.posts.append(contentsOf: posts)
                            vc.tableView.reloadData()
                            if posts.count == 0 {
                                vc.isLoadMoreEnabled = false
                            }
                        }
                    }, onError: { error in
                        print(error)
                    }
            )
        }
    }
    
}

extension ProfileViewController : MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
