//
//  Country.swift
//  CellExchange
//
//  Created by Alexander Hudym on 15.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

class Country : Object, Mappable {
    
    @objc dynamic var id = 0
    @objc dynamic var title = "All cities"
    @objc dynamic var isoCode2 = ""
    @objc dynamic var isoCode3 = ""
    @objc dynamic var dialCode = ""
    @objc dynamic var image = ""
    
    
    convenience required init(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        isoCode2 <- map["iso_code_2"]
        isoCode3 <- map["iso_code_3"]
        dialCode <- map["dial_code"]
        image <- map["image"]
    }
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    
}
