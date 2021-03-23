//
//  InfoManager.swift
//  CellExchange
//
//  Created by Alexander Hudym on 15.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import Foundation
import RealmSwift
import RxRealm
import Realm
import ObjectMapper
import RxAlamofire
import Alamofire

class InfoManager {
    
    static let instance = InfoManager()
    
    private init() {
        do {
            let realm = try Realm()
            try realm.write {
                if realm.objects(Country.self).count == 0 {
                    realm.add(get(Country.self, from: "countries.json"), update: true)
                }
                if realm.objects(Region.self).count == 0 {
                    realm.add(get(Region.self, from: "regions.json"), update: true)
                }
                if realm.objects(FreeZone.self).count == 0 {
                    realm.add(get(FreeZone.self, from: "freezones.json"), update: true)
                }
                if realm.objects(Category.self).count == 0 {
                    realm.add(get(Category.self, from: "categories.json"), update: true)
                }
                if realm.objects(Make.self).count == 0 {
                    realm.add(get(Make.self, from: "makes.json"), update: true)
                }
                if realm.objects(PhoneModel.self).count == 0 {
                    realm.add(get(PhoneModel.self, from: "models.json"), update: true)
                }
                if realm.objects(MakeToCategory.self).count == 0 {
                    realm.add(get(MakeToCategory.self, from: "make_to_categories.json"), update: true)
                }
                if realm.objects(StockType.self).count == 0 {
                    realm.add(get(StockType.self, from: "stock_types.json"), update: true)
                }
                if realm.objects(Condition.self).count == 0 {
                    realm.add(get(Condition.self, from: "conditions.json"), update: true)
                }
                if realm.objects(Specification.self).count == 0 {
                    realm.add(get(Specification.self, from: "specifications.json"), update: true)
                }
            }
        } catch {
            print(error)
        }
        
    }
    
    func getCountries() -> [Country] {
        let realm = try! Realm()
        return realm.objects(Country.self).toArray()
    }
    
    func getRegions(by countryId : Int) -> [Region] {
        let realm = try! Realm()
        return realm.objects(Region.self).filter("countryId=\(countryId)").toArray()
    }
    
    func getFreeZones() -> [FreeZone] {
        let realm = try! Realm()
        return realm.objects(FreeZone.self).toArray()
    }
    
    func getCategories() -> [Category] {
        let realm = try! Realm()
        return realm.objects(Category.self).toArray()
    }
    
    func getMakes(by categoryId : Int) -> [Make] {
        let realm = try! Realm()
        let makeToCategoryIds = realm.objects(MakeToCategory.self).filter("categoryId=\(categoryId)").toArray().map{$0.id}
        return realm.objects(Make.self).filter("id IN %@", makeToCategoryIds).toArray()
    }
    
    func getModels(by makeId : Int) -> [PhoneModel] {
        let realm = try! Realm()
        return realm.objects(PhoneModel.self).filter("makeId=\(makeId)").toArray()
    }
    
    func getStockTypes() -> [StockType] {
        let realm = try! Realm()
        return realm.objects(StockType.self).toArray()
    }
    
    func getConditions() -> [Condition] {
        let realm = try! Realm()
        return realm.objects(Condition.self).toArray()
    }
    
    func getSpecifications() -> [Specification] {
        let realm = try! Realm()
        return realm.objects(Specification.self).toArray()
    }
    
    func syncInfoWithCache() {
        syncWithCache(Country.self, path: "info/countries")
        syncWithCache(Region.self, path: "info/regions")
        syncWithCache(FreeZone.self, path: "info/freeZones")
        syncWithCache(Category.self, path: "info/categories")
        syncWithCache(Make.self, path: "info/makes")
        syncWithCache(PhoneModel.self, path: "info/models")
        syncWithCache(MakeToCategory.self, path: "info/makeToCategories")
        syncWithCache(StockType.self, path: "info/stockTypes")
        syncWithCache(Condition.self, path: "info/conditions")
        syncWithCache(Specification.self, path: "info/specifications")
    }
    
   
    
    
    func syncWithCache<T : Object & Mappable>(_ t : T.Type, path : String) {
        _ = RxAlamofire.json(.get, BASE_URL + path)
            .mapArray(t.self)
            .subscribe(onNext: { t in
                let realm = try! Realm()
                try! realm.write {
                    realm.add(t, update: true)
                }
            }, onError: { print($0) })
    }
    
    
    func get<T : Mappable>(_ t: T.Type, from fileNamed: String) -> [T] {
        let splitedFileName = fileNamed.split(separator: ".")
        if let path = Bundle.main.path(forResource: String(splitedFileName[0]), ofType: String(splitedFileName[1])), let jsonString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8), let models = Mapper<T>().mapArray(JSONString: jsonString) {
            return models
        }
        return []
    }
    
}


