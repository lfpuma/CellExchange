//
//  UserModel.swift
//  CellExchange
//
//  Created by Alexander Hudym on 15.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import Foundation
import ObjectMapper

class User: Mappable {
    
    var id = 0
    var fullName = ""
    var email = ""
    var registeredTradingName = ""
    var tradingLicenseNumber = ""
    var tradingLicenseValidFrom = ""
    var tradingLicenseValidTill = ""
    var businessProfile = ""
    var traderType : TraderType?
    var country : Country?
    var region : Region?
    var freeZone : FreeZone?
    var mobile = ""
    var officePhone = ""
    var officeMobile = ""
    var userGroup : UserGroup?
    var photo = ""
    var cover = ""
    var tradingLicense = ""
    var bill = ""
    var userPackage : UserPackage?
    var userInfo : String {
        var info = ""
        if let traderType = traderType {
            info += traderType.title + " | "
        }
        if let country = country {
            info += country.title
        }
        return info
    }
    
    init() {
        
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        fullName <- map["full_name"]
        email <- map["email"]
        registeredTradingName <- map["registered_trading_name"]
        tradingLicenseNumber <- map["trading_license_number"]
        tradingLicenseValidFrom <- map["trading_license_valid_from"]
        tradingLicenseValidTill <- map["trading_license_valid_till"]
        businessProfile <- map["business_profile"]
        traderType <- map["trader_type"]
        country <- map["country"]
        region <- map["region"]
        freeZone <- map["freeZone"]
        mobile <- map["mobile"]
        officePhone <- map["office_phone"]
        officeMobile <- map["office_mobile"]
        userGroup <- map["user_group"]
        photo <- map["photo"]
        cover <- map["cover"]
        tradingLicense <- map["trading_license"]
        bill <- map["bill"]
        userPackage <- map["package"]
    }
    
}
