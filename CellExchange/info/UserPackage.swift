//
//  UserPackage.swift
//  CellExchange
//
//  Created by Alexander Hudym on 15.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import Foundation
import ObjectMapper

class UserPackage : Mappable {
    
    var id = 0
    var title = ""
    var price = ""
    var duration = 0
    var durationType = ""
    
    init() {
        
    }
    
    convenience required init(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        price <- map["price"]
        duration <- map["duration"]
        durationType <- map["duration_type"]
    }
}
