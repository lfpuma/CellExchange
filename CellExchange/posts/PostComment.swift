//
//  PostComment.swift
//  CellExchange
//
//  Created by Alexander Hudym on 16.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import Foundation
import ObjectMapper

class PostComment : Mappable {
    var id = 0
    var message = ""
    var createdAt : Date?
    var user : User?
    var postId = 0
    var createdAtString : String {
        if let createdAt = createdAt {
            return AppDelegate.appDateFormat.string(from: createdAt)
        }
        return ""
    }
    
    init() {
        
    }
    
    convenience required init(map : Map) {
        self.init()
    }
    
    func mapping(map : Map) {
        id <- map["id"]
        message <- map["message"]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        createdAt <- (map["created_at"], DateFormatterTransform(dateFormatter: AppDelegate.serverDateFormat))
        user <- map["user"]
        postId <- map["post_id"]
    }
}
