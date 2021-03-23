//
//  Region.swift
//  CellExchange
//
//  Created by Alexander Hudym on 15.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

class Region : Object, Mappable {
    
    @objc dynamic var id = 0
    @objc dynamic var countryId = 0
    @objc dynamic var title = ""
    @objc dynamic var code = ""
    
    
    convenience required init(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        countryId <- map["country_id"]
        title <- map["title"]
        code <- map["code"]
    }
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    
}
