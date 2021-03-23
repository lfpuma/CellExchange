//
//  FreeZone.swift
//  CellExchange
//
//  Created by Alexander Hudym on 15.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

class FreeZone : Object, Mappable {
    
    @objc dynamic var id = 0
    @objc dynamic var countryId = 0
    @objc dynamic var zoneId = 0
    @objc dynamic var title = ""
    
    convenience required init(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        countryId <- map["country_id"]
        zoneId <- map["zone_id"]
        title <- map["title"]
    }
    
    override static func primaryKey() -> String {
        return "id"
    }
}
