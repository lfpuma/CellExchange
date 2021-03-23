//
//  HomeViewController.swift
//  CellExchange
//
//  Created by Alexander Hudym on 16.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit
import Floaty
import RxSwift
import RxCocoa
import ObjectMapper
import DZNEmptyDataSet
import Eureka

class HomeViewController: PostsViewController {
    
    enum EmptyState {
        case error
        case empty
    }

    let floaty = Floaty()
    let searchBar = UISearchBar()
    var selectedCountry = Country()
    let toolbar = NavigationAccessoryView()
    var emptyState : EmptyState = .empty
    
    var isLoadMoreShowing = false
    var isloadMoreEnabled = true
    var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.placeholder = "What are you looking for?"
        let searchBarFrame = CGRect(x: 0, y: 0, width: view.frame.width * 0.7, height: 30)
        searchBar.frame = searchBarFrame
        if #available(iOS 11.0, *) {
            let wrapView = UIView(frame: searchBarFrame)
            searchBar.setSearchFieldBackgroundImage(UIImage.searchFieldBackgroundImage(), for: .normal)
            wrapView.addSubview(searchBar)
            navigationItem.titleView = wrapView
        } else {
            navigationItem.titleView = searchBar
        }
        searchBar.delegate = self
        searchBar.inputAccessoryView = toolbar
        
        toolbar.previousButton.isEnabled = false
        toolbar.nextButton.isEnabled = false
        toolbar.doneButton.target = self
        toolbar.doneButton.action = #selector(doneDidClick(_:))
        
        
        navigationItem.setLeftBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "ic_profile"), style: .plain, target: self, action: #selector(profileDidClick)), animated: true)
        navigationItem.setRightBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "ic_filter"), style: .plain, target: self, action: #selector(filterDidClick)), animated: true)
        
        floaty.buttonColor = #colorLiteral(red: 0.2167961299, green: 0.6839216352, blue: 0.874153614, alpha: 1)
        floaty.buttonImage = #imageLiteral(resourceName: "ic_edit")
        floaty.fabDelegate = self
        view.addSubview(floaty)
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        _ = searchBar.rx.text.orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { _ in
                print("search")
                self.currentPage = 1
                self.isloadMoreEnabled = true
                self.getPosts()
            }, onError: {print($0)} )
        
        NotificationCenter.default.addObserver(self, selector: #selector(newPostDidReceive), name: Notification.Name(AppDelegate.newPostActionKey), object: nil)
        
    }
    
    @objc func doneDidClick(_ sender: UIBarButtonItem) {
        searchBar.resignFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(AppDelegate.newPostActionKey), object: nil)
    }
    
    @objc func newPostDidReceive(_ notification : Notification) {
        if let userInfo = notification.userInfo as? [String : Any], let post = Mapper<Post>().map(JSON: userInfo) {
            if let index = posts.index(where: {$0.id == post.id}) {
                posts[index] = post
                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            } else {
                posts.insert(post, at: 0)
                tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
        }
    }
    
    override func refreshDidRequest() {
        currentPage = 1
        isloadMoreEnabled = true
        getPosts()
    }
    
    @objc func profileDidClick(_ sender: UIBarButtonItem) {
        let profileViewController = ProfileViewController()
        navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    @objc func filterDidClick(_ sender: UIBarButtonItem) {
        let homeFilterViewController = HomeFilterViewController()
        homeFilterViewController.selectedCountry = selectedCountry
        homeFilterViewController.delegate = self
        navigationController?.pushViewController(homeFilterViewController, animated: true)
    }
    
    @objc func fabDidClick() {
        let newPostViewController = NewPostViewController()
        navigationController?.pushViewController(newPostViewController, animated: true)
    }

    
    func getPosts() {
        _ = PostManager.instance.getPosts(countryId: selectedCountry.id == 0 ? nil : selectedCountry.id, keyword: searchBar.text, page: currentPage, perPage: 25)
            .do(onSubscribe: { [weak self] in
                if let vc = self {
                    if vc.currentPage == 1 {
                        vc.beginRefreshing()
                    } else {
                        vc.isLoadMoreShowing = true
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
                }
            }, onDispose: { [weak self] in
                if let vc = self {
                    vc.endRefreshing()
                    vc.tableView.tableFooterView = nil
                    vc.isLoadMoreShowing = false
                }
            })
            .subscribe(onNext: { [weak self] posts in
                if let vc = self {
                    if vc.currentPage == 1 {
                        vc.posts.removeAll()
                    }
                    if posts.count == 0, vc.currentPage > 1 {
                        vc.isloadMoreEnabled = false
                    }
                    vc.posts.append(contentsOf: posts)
                    vc.emptyState = .empty
                    vc.tableView.reloadData()
                    vc.currentPage += 1
                }
            }, onError: { [weak self] error in
                print(error)
                if let vc = self {
                    if vc.currentPage == 1 {
                        vc.posts.removeAll()
                        vc.emptyState = .error
                        vc.tableView.reloadData()
                    }
                }
                
            })
    }
    
    override func keyboardWillShow(_ notification: Notification) {
        super.keyboardWillShow(notification)
        floaty.isHidden = true
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        super.keyboardWillHide(notification)
        floaty.isHidden = false
    }

    override func nameDidClick(at cell : PostTableViewCell) {
        if let index = tableView.indexPath(for: cell) {
            let post = posts[index.row]
            if let user = post.user {
                let profileViewController = ProfileViewController()
                profileViewController.userId = user.id
                navigationController?.pushViewController(profileViewController, animated: true)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rowIndex = indexPath.row
        if isloadMoreEnabled, !isLoadMoreShowing, posts.count > 5, rowIndex + 5 >= posts.count {
            getPosts()
        }
    }
    
}

extension HomeViewController : DZNEmptyDataSetSource {
    
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: emptyState == .empty ? "No posts" : "Error loading. Try again later")
    }
    
}

extension HomeViewController : DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldFade(in scrollView: UIScrollView!) -> Bool {
        return true
    }
    
}
extension HomeViewController : NewPostDelegate {
    
    func onCreate(new post: Post) {
        
        if let index = posts.index(where: {$0.id == post.id}) {
            posts[index] = post
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        } else {
            posts.insert(post, at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
    }
    
}

extension HomeViewController : HomeFilterDelegate {
    
    func countryDidSelect(country: Country) {
        selectedCountry = country
        currentPage = 1
        isloadMoreEnabled = true
        getPosts()
        navigationItem.setRightBarButton(UIBarButtonItem(image: selectedCountry.id == 0 ? #imageLiteral(resourceName: "ic_filter") : #imageLiteral(resourceName: "ic_filtered").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(filterDidClick)), animated: true)
    }
    
}

extension HomeViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        currentPage = 1
        isloadMoreEnabled = true
        getPosts()
        searchBar.resignFirstResponder()
    }
}

extension HomeViewController : FloatyDelegate {
    
    func emptyFloatySelected(_ floaty: Floaty) {
        let newPostViewController = NewPostViewController()
        newPostViewController.delegate = self
        navigationController?.pushViewController(newPostViewController, animated: true)
        
    }
    
}
