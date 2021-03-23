//
//  Post.swift
//  CellExchange
//
//  Created by Alexander Hudym on 15.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import UIKit
import ObjectMapper



class Post : Mappable {
    
    var id = 0
    var reference = ""
    var user : User?
    var adTitle = ""
    var interestInId = 0
    var category : Category?
    var make : Make?
    var photo = ""
    var modelNumber = ""
    var stockType : StockType?
    var color = ""
    var storageCapacity = ""
    var condition : Condition?
    var specification : Specification?
    var qty = 0
    var description = ""
    var status = 0
    var createdAt : Date?
    var isLiked = false
    var s = ""
    
    var createdAtString : String {
        if let createdAt = createdAt {
            return AppDelegate.appDateFormat.string(from: createdAt)
        }
        return ""
    }
    
    var productInfo : String {
        var info = ""
        if !modelNumber.isEmpty {
            info += modelNumber + " | "
        }
        if let stockType = stockType, !stockType.title.isEmpty {
            info += stockType.title + " | "
        }
        if !color.isEmpty {
            info += color + " | "
        }
        if !storageCapacity.isEmpty {
            info += storageCapacity + "GB | "
        }
        if let condition = condition, !condition.title.isEmpty {
            info += condition.title + " | "
        }
        if let specification = specification, !specification.title.isEmpty {
            info += specification.title + " | "
        }
        if qty != 0 {
            info += "\(qty) Qty "
        }
        return info
    }
    
    var interestIn : String {
        return interestInId == 1 ? "WTS" :  interestInId == 2 ? "WTB" : "Service"
    }
    
    init() {
        
    }
    
    convenience required init?(map: Map) {
        self.init()
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        reference <- map["reference"]
        user <- map["user"]
        adTitle <- map["ad_title"]
        interestInId <- map["interested_in_id"]
        category <- map["category"]
        make <- map["make"]
        photo <- map["photoSrc"]
        modelNumber <- map["model_number"]
        stockType <- map["stock_type"]
        color <- map["color"]
        storageCapacity <- map["storage_capacity"]
        condition <- map["product_condition"]
        specification <- map["specification"]
        qty <- map["qty"]
        description <- map["description"]
        status <- map["status"]
        createdAt <- (map["created_at"], DateFormatterTransform(dateFormatter: AppDelegate.serverDateFormat))
        s <- map["created_at"]
        isLiked <- map["is_liked"]
    }
}
