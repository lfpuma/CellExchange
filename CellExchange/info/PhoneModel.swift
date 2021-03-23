//
//  Model.swift
//  CellExchange
//
//  Created by Alexander Hudym on 20.10.17.
//Copyright © 2017 CellExchange. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class PhoneModel: Object, Mappable {
   
    @objc dynamic var id = 0
    @objc dynamic var title = ""
    @objc dynamic var makeId = 0
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        makeId <- map["make_id"]
    }
    
    override static func primaryKey() -> String {
        return "id"
    }
}
