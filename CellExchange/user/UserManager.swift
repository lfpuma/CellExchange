//
//  UserManager.swift
//  CellExchange
//
//  Created by Alexander Hudym on 15.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit
import RxAlamofire
import RxSwift
import Alamofire



class UserManager {
    
    static let instance = UserManager()
    
    var token: String? = {
        return UserDefaults.standard.string(forKey: "token")
    } () {
        willSet(newValue) {
            UserDefaults.standard.set(newValue, forKey: "token")
        }
    }
    
    var isLoggedIn = {
        return UserDefaults.standard.string(forKey: "token") != nil
    } ()
    
    var currentUserId: Int = {
        return UserDefaults.standard.integer(forKey: "current_user_id")
    } () {
        willSet(newValue) {
            UserDefaults.standard.set(newValue, forKey: "current_user_id")
        }
    }
    
    private init() {
        
    }
    
    func signIn(email: String, password: String) -> Observable<Any> {
        return RxAlamofire.json(.post, BASE_URL + "users/login", parameters: ["email": email, "password": password])
    }
    
    func forgotPassword(email: String) -> Observable<Any> {
        return RxAlamofire.json(.post, BASE_URL + "users/forgotPassword", parameters: ["email" : email])
    }
    
    func signUp(email: String, password: String, fullName: String, countryId: Int, regionId: Int, mobile: String, isFreeZone: Bool, freeZoneId: Int?) -> Observable<User> {
        return RxAlamofire.json(.post, BASE_URL + "users/register", parameters: ["email" : email, "password" : password, "full_name" : fullName, "country_id" : countryId, "zone_id" : regionId, "mobile" : mobile, "is_freezone" : isFreeZone, "freezone_id" : freeZoneId ?? ""]).debug().mapObject(User.self)
    }
    
    func sendFirebaseToken(token: String) -> Observable<Any> {
        return RxAlamofire.json(.post, BASE_URL + "users/firebaseToken", parameters: ["firebase_token" : token])
    }
    
    func getUsers() -> Observable<[User]> {
        return RxAlamofire.json(.get, BASE_URL + "users/").mapArray(User.self)
    }
    
    func getUser(by id: Int) -> Observable<User> {
        return RxAlamofire.json(.get, BASE_URL + "users/\(id)").mapObject(User.self)
    }
    
    func logout() {
        token = nil
        currentUserId = 0
    }
    
    
}

class AuthRetrier : RequestRetrier {
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        
        
        if let task = request.task, let response = task.response as? HTTPURLResponse, response.statusCode == 401 {
            UserManager.instance.logout()
            DispatchQueue.main.async {
                
                if let topViewController = UIApplication.topViewController() {
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    if let signInViewController = storyboard.instantiateViewController(withIdentifier: "login") as? LoginViewController {
                        topViewController.present(signInViewController, animated: true, completion: nil)
                    }
                }
                
            }
        }
        completion(false, 0)
    }
}

class TokenAdapter: RequestAdapter {
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var request = urlRequest
        if let token = UserManager.instance.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Token")
        }
        return request
    }
    
}
