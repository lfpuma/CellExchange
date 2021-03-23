//
//  PostViewController.swift
//  CellExchange
//
//  Created by Alexander Hudym on 16.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit
import AlamofireImage
import SVProgressHUD
import ObjectMapper

class PostViewController: UIViewController {

    var post = Post()
    var requestComment = false
    var postComments = [PostComment]()
    
    lazy var tableView = UITableView()
    lazy var messageTextField = UITextField()
    lazy var bottomView = UIView()
    lazy var sendButton = UIButton()
    lazy var postView : PostDetailsView = {
        return UINib(nibName: "PostDetailsView", bundle: Bundle.main)
            .instantiate(withOwner: self, options: nil).first as! PostDetailsView
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Details"
        
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tableView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tableView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
        bottomView.backgroundColor = #colorLiteral(red: 0.2167961299, green: 0.6839216352, blue: 0.874153614, alpha: 1)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomView)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: bottomView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 52),
            NSLayoutConstraint(item: bottomView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bottomView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bottomView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
            ])
        
        sendButton.setImage(#imageLiteral(resourceName: "ic_send"), for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendDidClick), for: .touchUpInside)
        bottomView.addSubview(sendButton)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: sendButton, attribute: .trailing, relatedBy: .equal, toItem: bottomView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: sendButton, attribute: .top, relatedBy: .equal, toItem: bottomView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: sendButton, attribute: .bottom, relatedBy: .equal, toItem: bottomView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: sendButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 52)
            ])
        
        
        messageTextField.placeholder = "Message"
        messageTextField.borderStyle = .roundedRect
        messageTextField.keyboardType = .default
        messageTextField.returnKeyType = .send
        messageTextField.delegate = self
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(messageTextField)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: messageTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: messageTextField, attribute: .centerY, relatedBy: .equal, toItem: bottomView, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: messageTextField, attribute: .leading, relatedBy: .equal, toItem: bottomView, attribute: .leading, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: messageTextField, attribute: .right, relatedBy: .equal, toItem: sendButton, attribute: .left, multiplier: 1, constant: -8)
            ])
        
        tableView.register(UINib(nibName: "PostCommentTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "post_comment_cell")
        
        postView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = postView
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: postView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
            ])
       
        invalidateLabels()
        
        _ = PostManager.instance.getComments(for: post.id)
            .subscribe(onNext: { [weak self] comments in
                if let vc = self {
                    vc.postComments = comments
                    vc.tableView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if vc.requestComment {
                            vc.requestComment = false
                            vc.messageTextField.becomeFirstResponder()
                        }
                    }
                }
            }, onError: { error in
                print(error)
            })
        
        
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 52))
        
        postView.delegate = self
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(outsideDidTap)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(commentDidReceive), name: Notification.Name(AppDelegate.newCommentActionKey), object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(AppDelegate.newCommentActionKey), object: nil)
    }
    
    @objc func outsideDidTap() {
        view.endEditing(true)
    }
    
    @objc func commentDidReceive(_ notifiation : Notification) {
        if let userInfo = notifiation.userInfo as? [String : Any], let comment = Mapper<PostComment>().map(JSON: userInfo) {
            if !postComments.contains(where: { $0.id == comment.id }) {
                postComments.append(comment)
                let index = IndexPath(row: postComments.count - 1, section: 0)
                tableView.scrollToRow(at: index, at: .top, animated: true)
                tableView.reloadData()
            }
        }
    }
    
    @objc func sendDidClick() {
        messageTextField.resignFirstResponder()
        if let message = messageTextField.text, !message.isEmpty {
            _ = PostManager.instance.sendComment(for: post.id, with: message)
                .do(onSubscribe: { SVProgressHUD.show() }, onDispose: { SVProgressHUD.dismiss() } )
                .subscribe(onNext: { [weak self] comment in
                    self?.messageTextField.text = ""
                    self?.postComments.append(comment)
                    self?.tableView.reloadData()
                }, onError: { [weak self] error in
                    print(error)
                    let sendErrorAlert = UIAlertController(title: nil, message: "Send message failed. Try again later", preferredStyle: .alert)
                    sendErrorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(sendErrorAlert, animated: true, completion: nil)
                })
        } else {
            let sendErrorAlert = UIAlertController(title: nil, message: "Message can not be empty", preferredStyle: .alert)
            sendErrorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(sendErrorAlert, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParentViewController {
            if let postsViewController = navigationController?.viewControllers.last as? PostsViewController {
                if let postIndex = postsViewController.posts.index(where: { $0.id == post.id }) {
                    postsViewController.posts[postIndex] = post
                    postsViewController.tableView.reloadRows(at: [IndexPath(row: postIndex, section: 0)], with: .automatic)
                }
            }
        }
    }
    
    @objc func keyboardWillShow(_ notification : Notification) {
        if let info = notification.userInfo, let keyboardFrame = info[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            UIView.animate(withDuration: 0.3) {
                self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
                self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
                self.bottomView.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.height)
            }
            if let footer = tableView.tableFooterView {
                tableView.scrollRectToVisible(footer.frame, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification : Notification) {
        UIView.animate(withDuration: 0.3) {
            self.tableView.contentInset = .zero
            self.tableView.scrollIndicatorInsets = .zero
            self.bottomView.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    func invalidateLabels() {
        if let user = post.user {
            if let avatarUrl = URL(string: user.photo) {
                postView.avatarImageView.af_setImage(withURL: avatarUrl,  placeholderImage: #imageLiteral(resourceName: "ic_no_avatar_list"), filter: AspectScaledToFillSizeCircleFilter(size: postView.avatarImageView.frame.size))
            } else {
                postView.avatarImageView.image = #imageLiteral(resourceName: "ic_no_avatar_list")
            }
            postView.nameButton.setTitle(user.fullName, for: .normal)
            postView.userInfoLabel.text = user.userInfo
        }
        postView.dateLabel.text = post.createdAtString
        postView.interestedInlabel.text = post.interestIn
        postView.productLabel.text = post.adTitle
        postView.productInfoLabel.text = post.productInfo
        postView.productDescriptionLabel.text = post.description
        if let photoUrl = URL(string: post.photo) {
            postView.photoImageView.af_setImage(withURL: photoUrl)
            postView.photoImageViewHeightConstraint.constant = 192
        } else {
            postView.photoImageView.image = nil
            postView.photoImageViewHeightConstraint.constant = 0
        }
        postView.likeButton.setImage(post.isLiked ? #imageLiteral(resourceName: "ic_liked") : #imageLiteral(resourceName: "ic_like"), for: .normal)
        postView.likeButton.setTitleColor(post.isLiked ? #colorLiteral(red: 0.2167961299, green: 0.6839216352, blue: 0.874153614, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
    }
    
}

extension PostViewController : PostDetailsViewDelegate {
    
    func nameDidClick() {
        if let user = post.user {
            let profileViewController = ProfileViewController()
            profileViewController.userId = user.id
            navigationController?.pushViewController(profileViewController, animated: true)
        }
    }
    
    func likeDidClick() {
        _ = PostManager.instance.like(for: post.id, action: !post.isLiked)
            .do(onSubscribe: { SVProgressHUD.show() }, onDispose: { SVProgressHUD.dismiss() } )
            .subscribe(onNext: { [weak self] post in
                self?.post = post
                self?.invalidateLabels()
                }, onError: { error in
                    print(error)
            })
    }
    
    func shareDidClick() {
        PostManager.share(post: post)
    }
    
}

extension PostViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        sendDidClick()
        return true
    }
}

extension PostViewController : UITableViewDelegate, UITableViewDataSource {

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postCommentCell = tableView.dequeueReusableCell(withIdentifier: "post_comment_cell", for: indexPath) as! PostCommentTableViewCell
        let comment = postComments[indexPath.row]
        
        if let user = comment.user {
            
            if let avatarUrl = URL(string: user.photo) {
                postCommentCell.avatarImageView.af_setImage(withURL: avatarUrl, placeholderImage: #imageLiteral(resourceName: "ic_no_avatar_list"), filter: AspectScaledToFillSizeCircleFilter(size: postCommentCell.avatarImageView.frame.size))
            } else {
                postCommentCell.avatarImageView.image = #imageLiteral(resourceName: "ic_no_avatar_list")
            }
            
            postCommentCell.nameLabel.text = user.fullName
            
            if user.id == UserManager.instance.currentUserId {
                NSLayoutConstraint.activate([
                    NSLayoutConstraint(item: postCommentCell.avatarImageView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: postCommentCell.contentView, attribute: .leading, multiplier: 1, constant: 40),
                    NSLayoutConstraint(item: postCommentCell.timeLabel, attribute: .trailing, relatedBy: .equal, toItem: postCommentCell.contentView, attribute: .trailing, multiplier: 1, constant: 20)
                    ])
            } else {
                NSLayoutConstraint.activate([
                    NSLayoutConstraint(item: postCommentCell.avatarImageView, attribute: .leading, relatedBy: .equal, toItem: postCommentCell.contentView, attribute: .leading, multiplier: 1, constant: 20),
                    NSLayoutConstraint(item: postCommentCell.timeLabel, attribute: .trailing, relatedBy: .greaterThanOrEqual, toItem: postCommentCell.contentView, attribute: .trailing, multiplier: 1, constant: 40)
                    ])
            }
            
        }
        
        postCommentCell.messageLabel.text = comment.message
        postCommentCell.timeLabel.text = comment.createdAtString
        
        return postCommentCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postComments.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
}

