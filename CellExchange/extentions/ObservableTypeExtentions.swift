//
//  ObservableTypeExtentions.swift
//  MyEurope
//
//  Created by Alexander Hudym on 16.05.17.
//  Copyright © 2017 MyEurope. All rights reserved.
//

import UIKit
import RxSwift
import RxAlamofire
import ObjectMapper

extension ObservableType {
    public func mapObject<T: Mappable>(_ type: T.Type) -> Observable<T> {
        return flatMap { data -> Observable<T> in
            guard let object = Mapper<T>().map(JSONObject: data) else {
                throw NSError(
                    domain: "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "ObjectMapper can't mapping"]
                )
            }
            
            return Observable.just(object)
        }
    }
    
    public func mapArray<T: Mappable>(_ type: T.Type) -> Observable<[T]> {
        return flatMap { data -> Observable<[T]> in
            guard let objects = Mapper<T>().mapArray(JSONObject: data) else {
                throw NSError(
                    domain: "",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "ObjectMapper can't mapping"]
                )
            }
            
            return Observable.just(objects)
        }
    }
}
