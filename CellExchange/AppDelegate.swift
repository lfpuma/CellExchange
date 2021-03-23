//
//  AppDelegate.swift
//  CellExchange
//
//  Created by Alexander Hudym on 28.09.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SVProgressHUD
import UserNotifications
import ObjectMapper
import RxSwift
import RealmSwift

public let BASE_URL = "http://cell.exchange/api/v1/"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    static let serverDateFormat : DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()
    
    static let appDateFormat : DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm dd.MM.yyyy"
        return dateFormatter
    } ()
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        application.statusBarStyle = .lightContent
        
        Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true
    
        if let window = window, let rootViewController = window.rootViewController, let storyboard = rootViewController.storyboard {
            
            if UserManager.instance.isLoggedIn {
                window.rootViewController = MainViewController(rootViewController: HomeViewController())
            } else {
                window.rootViewController = storyboard.instantiateViewController(withIdentifier: "login")
            }
            
            window.makeKeyAndVisible()
        }
        
        SVProgressHUD.setDefaultMaskType(.clear)
        
        SessionManager.default.adapter = TokenAdapter()
        SessionManager.default.retrier = AuthRetrier()
        
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound],
            completionHandler: { print($0, $1 as Any) })
        
        application.registerForRemoteNotifications()
        
        InfoManager.instance.syncInfoWithCache()
        
        return true
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        initNotification(data: userInfo)
        completionHandler(.newData)
    }
    
    
    func initNotification(data: [AnyHashable : Any]) {
        if let action = data[AppDelegate.actionKey] as? String {
            switch action {
            case AppDelegate.likeActionKey:
                if let type = data["type"] as? String, let postId = data["post_id"] as? String, let likedById = data["liked_by_id"] as? String {
                    _ = Observable.combineLatest(PostManager.instance.getPost(id: Int(postId)!), UserManager.instance.getUser(by: Int(likedById)!)) { ($0, $1) }
                        .subscribe(onNext: { post, user in
                            let content = UNMutableNotificationContent()
                            content.title = "Your post is \(type)"
                            content.body = "\(user.fullName) \(type) your post \(post.adTitle)"
                            content.userInfo = Mapper<Post>().toJSON(post)
                            content.sound = UNNotificationSound.default()
                            content.categoryIdentifier = action
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                            let request = UNNotificationRequest(identifier: String(Date().timeIntervalSince1970), content: content, trigger: trigger)
                            UNUserNotificationCenter.current().add(request) { print($0 as Any) }
                        }, onError: { print($0) })
                }
                break
            case AppDelegate.newPostActionKey:
                if let postId = data["post_id"] as? String {
                    _ = PostManager.instance.getPost(id: Int(postId)!)
                        .subscribe(onNext: { post in
                            
                            if let user = post.user {
                                let content = UNMutableNotificationContent()
                                content.title = "Added a new psot"
                                content.body = "\(user.fullName) added a new post \(post.adTitle)"
                                content.userInfo = Mapper<Post>().toJSON(post)
                                content.sound = UNNotificationSound.default()
                                content.categoryIdentifier = action
                                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                                let request = UNNotificationRequest(identifier: String(Date().timeIntervalSince1970), content: content, trigger: trigger)
                                UNUserNotificationCenter.current().add(request) { print($0 as Any) }
                            }
                            
                            NotificationCenter.default.post(name: Notification.Name(action), object: nil, userInfo: Mapper<Post>().toJSON(post))
                            
                        }, onError: { print($0) } )
                }
                break
            case AppDelegate.newCommentActionKey:
                if let commentId = data["comment_id"] as? String {
                    _ = PostManager.instance.getComment(by: Int(commentId)!)
                        .flatMap { Observable.combineLatest(PostManager.instance.getPost(id: $0.postId), Observable.just($0)) { ($0, $1) } }
                        .subscribe(onNext: { post, comment in
                            if let user = post.user, user.id == UserManager.instance.currentUserId {
                                let content = UNMutableNotificationContent()
                                content.title = "You received a comment"
                                content.body = "\(user.fullName) commented on your post \(post.adTitle)"
                                content.userInfo = Mapper<Post>().toJSON(post)
                                content.sound = UNNotificationSound.default()
                                content.categoryIdentifier = action
                                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                                let request = UNNotificationRequest(identifier: String(Date().timeIntervalSince1970), content: content, trigger: trigger)
                                UNUserNotificationCenter.current().add(request) { print($0 as Any) }
                            }
                            
                            NotificationCenter.default.post(name: Notification.Name(action), object: nil, userInfo: Mapper<PostComment>().toJSON(comment))
                        }, onError: { print($0) })
                }
                break
            default:
                break
            }
        }
    }
    
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }

    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let request = response.notification.request
        let content = request.content
        
        if let userInfo = content.userInfo as? [String : Any], let topViewController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController  {
            let identifier = content.categoryIdentifier
            if identifier == AppDelegate.likeActionKey || identifier == AppDelegate.newCommentActionKey || identifier == AppDelegate.newPostActionKey {
                if let post = Mapper<Post>().map(JSON: userInfo)  {
                    let postViewController = PostViewController()
                    postViewController.post = post
                    topViewController.pushViewController(postViewController, animated: true)
                }
            }
        }
        completionHandler()
    }
    
    
    
    
}

extension AppDelegate : MessagingDelegate {

    static let actionKey = "action"
    static let likeActionKey = "like"
    static let newPostActionKey = "new_post"
    static let newCommentActionKey = "new_comment"
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        if UserManager.instance.isLoggedIn {
            _ = UserManager.instance.sendFirebaseToken(token: fcmToken)
                .subscribe(onNext: { _ in }, onError: { print($0) } )
        }
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        initNotification(data: remoteMessage.appData)
        
    }
    
}

extension UIApplication {
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController?
    {
        if let nav = base as? UINavigationController
        {
            let top = topViewController(nav.visibleViewController)
            return top
        }
        
        if let tab = base as? UITabBarController
        {
            if let selected = tab.selectedViewController
            {
                let top = topViewController(selected)
                return top
            }
        }
        
        if let presented = base?.presentedViewController
        {
            let top = topViewController(presented)
            return top
        }
        return base
    }
}



