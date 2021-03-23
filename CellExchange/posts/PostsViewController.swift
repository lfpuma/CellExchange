//
//  PostsViewController.swift
//  CellExchange
//
//  Created by Alexander Hudym on 29.09.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit
import AlamofireImage
import SVProgressHUD

class PostsViewController: UIViewController, PostCellDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView()
    let refreshControl = UIRefreshControl()

    var posts = [Post]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        view.addSubview(tableView)
        tableView.refreshControl = refreshControl
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "post_cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tableView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tableView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        refreshControl.addTarget(self, action: #selector(refreshDidRequest), for: .valueChanged)
        
    }
    
    func beginRefreshing() {
        refreshControl.beginRefreshing()
        tableView.setContentOffset(CGPoint(x: 0, y: -self.refreshControl.frame.height), animated: true)
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
    }
    
    @objc func refreshDidRequest() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo, let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postCell = tableView.dequeueReusableCell(withIdentifier: "post_cell", for: indexPath) as! PostTableViewCell
        
        let post = posts[indexPath.row]
        if let user = post.user {
            if let avatarUrl = URL(string: user.photo) {
                postCell.avatarImageView.af_setImage(withURL: avatarUrl,  placeholderImage: #imageLiteral(resourceName: "ic_no_avatar_list"), filter: AspectScaledToFillSizeCircleFilter(size: postCell.avatarImageView.frame.size))
            } else {
                postCell.avatarImageView.image = #imageLiteral(resourceName: "ic_no_avatar_list")
            }
            postCell.nameButton.setTitle(user.fullName, for: .normal)
            postCell.userInfoLabel.text = user.userInfo
        }
        postCell.dateLabel.text = post.createdAtString
        postCell.interestedInlabel.text = post.interestIn
        postCell.interestedInlabel.textColor = post.interestInId == 1 ? #colorLiteral(red: 0.9568627451, green: 0.368627451, blue: 0.02352941176, alpha: 1) : #colorLiteral(red: 0.2156862745, green: 0.6823529412, blue: 0.8745098039, alpha: 1)
        postCell.productLabel.text = post.adTitle
        postCell.productInfoLabel.text = post.productInfo
        postCell.productDescriptionLabel.text = post.description
        if let photoUrl = URL(string: post.photo) {
            postCell.photoImageView.af_setImage(withURL: photoUrl)
            postCell.photoImageViewHeightConstraint.constant = 192
        } else {
            postCell.photoImageView.image = nil
            postCell.photoImageViewHeightConstraint.constant = 0
        }
        postCell.likeButton.setImage(post.isLiked ? #imageLiteral(resourceName: "ic_liked") : #imageLiteral(resourceName: "ic_like"), for: .normal)
        postCell.likeButton.setTitleColor(post.isLiked ? #colorLiteral(red: 0.2156862745, green: 0.6823529412, blue: 0.8745098039, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        
        postCell.invalidateSizeForLabels()
        
        postCell.delegate = self
        
        return postCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let postViewController = PostViewController()
        postViewController.post = posts[indexPath.row]
        navigationController?.pushViewController(postViewController, animated: true)
    }
    
    func nameDidClick(at cell : PostTableViewCell) {
        
    }
    
    func likeDidClick(at cell: PostTableViewCell) {
        if let index = tableView.indexPath(for: cell) {
            let post = posts[index.row]
            _ = PostManager.instance.like(for: post.id, action: !post.isLiked)
                .do(onSubscribe: { SVProgressHUD.show() }, onDispose: { SVProgressHUD.dismiss() } )
                .subscribe(onNext: { [weak self] post in
                    self?.posts[index.row] = post
                    self?.tableView.reloadRows(at: [index], with: .automatic)
                }, onError: { error in
                    print(error)
                })
        }
    }
    
    func commentDidClick(at cell: PostTableViewCell) {
        if let index = tableView.indexPath(for: cell) {
            let postViewController = PostViewController()
            postViewController.post = posts[index.row]
            postViewController.requestComment = true
            navigationController?.pushViewController(postViewController, animated: true)
        }
    }
    
    func shareDidClick(at cell: PostTableViewCell) {
        if let index = tableView.indexPath(for: cell) {
            PostManager.share(post: posts[index.row])
        }
    }
    
    
    
}



