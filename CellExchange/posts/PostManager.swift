//
//  PostManager.swift
//  CellExchange
//
//  Created by Alexander Hudym on 15.10.17.
//  Copyright © 2017 CellExchange. All rights reserved.
//

import Foundation
import Alamofire
import RxAlamofire
import RxSwift
import ObjectMapper

class PostManager {
    
    static let instance = PostManager()
    
    private init() {
        
    }
    
    func getPosts(userId: Int? = nil, countryId: Int? = nil, keyword: String? = nil, page : Int, perPage : Int) -> Observable<[Post]> {
        return RxAlamofire.json(.get, BASE_URL + "posts/", parameters: ["user_id": userId ?? "", "country_id" : countryId ?? "", "keyword" : keyword ?? "", "page" : page, "per-page" : perPage]).mapArray(Post.self)
    }
    
    func getPost(id : Int) -> Observable<Post> {
        return RxAlamofire.json(.get, BASE_URL + "posts/\(id)").mapObject(Post.self)
    }
    
    func like(for postId : Int, action : Bool) -> Observable<Post> {
        return RxAlamofire.json(.post, BASE_URL + "posts/like", parameters: ["post_id" : postId, "action" : String(action)]).mapObject(Post.self)
    }
    
    func getComments(for postId : Int) -> Observable<[PostComment]> {
        return RxAlamofire.json(.get, BASE_URL + "posts/comments", parameters: ["post_id" : postId]).mapArray(PostComment.self)
    }
    
    func getComment(by id : Int) -> Observable<PostComment> {
        return RxAlamofire.json(.get, BASE_URL + "posts/comment", parameters: ["id" : id]).mapObject(PostComment.self)
    }
    
    func sendComment(for postId : Int, with message : String) -> Observable<PostComment> {
        return RxAlamofire.json(.post, BASE_URL + "posts/sendComment", parameters: ["post_id" : postId, "message" : message]).mapObject(PostComment.self)
    }
    
    
    func create(interestedInId : Int, categoryId : Int, makeId : Int, modelId : Int, modelNumber : String?, stockTypeId : Int, color : String?, storageCapacity : Int?, productConditionId : Int, specificationId : Int, qty : Int, description : String?, photo : UIImage?) -> Observable<Post> {
        
        return Observable.create { emmiter in
            
            Alamofire.upload(multipartFormData: { multipartFormData in
                if let interestInData = "\(interestedInId)".data(using: .utf8) {
                    multipartFormData.append(interestInData, withName: "interested_in_id")
                }
                if let categoryIdData = "\(categoryId)".data(using: .utf8) {
                    multipartFormData.append(categoryIdData, withName: "product_category_id")
                }
                if let makeIdData = "\(makeId)".data(using: .utf8) {
                    multipartFormData.append(makeIdData, withName: "make_id")
                }
                if let modelIdData = "\(modelId)".data(using: .utf8) {
                    multipartFormData.append(modelIdData, withName: "model_id")
                }
                if let modelNumber = modelNumber, let modelNumberData = "\(modelNumber)".data(using: .utf8) {
                    multipartFormData.append(modelNumberData, withName: "model_number")
                }
                if let stockTypeIdData = "\(stockTypeId)".data(using: .utf8) {
                    multipartFormData.append(stockTypeIdData, withName: "stock_type_id")
                }
                if let color = color, let colorData = color.data(using: .utf8) {
                    multipartFormData.append(colorData, withName: "color")
                }
                if let storageCapacity = storageCapacity, let storageCapacityData = "\(storageCapacity)".data(using: .utf8) {
                    multipartFormData.append(storageCapacityData, withName: "storage_capacity")
                }
                if let productConditionIdData = "\(productConditionId)".data(using: .utf8) {
                    multipartFormData.append(productConditionIdData, withName: "product_condition")
                }
                if let specificationIdData = "\(specificationId)".data(using: .utf8) {
                    multipartFormData.append(specificationIdData, withName: "specification_id")
                }
                if let qtyData = "\(qty)".data(using: .utf8) {
                    multipartFormData.append(qtyData, withName: "qty")
                }
                if let description = description, let descriptionData = description.data(using: .utf8) {
                    multipartFormData.append(descriptionData, withName: "description")
                }
                if let photo = photo, let photoData = UIImageJPEGRepresentation(photo, 1) {
                    multipartFormData.append(photoData, withName: "photo", fileName: String(Date().timeIntervalSince1970), mimeType: "image/*")
                }
            }, usingThreshold: UInt64.init(), to: BASE_URL + "posts/create/", method: .post) { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let json = response.result.value as? [String : Any], let post = Mapper<Post>().map(JSON: json) {
                            emmiter.onNext(post)
                            emmiter.onCompleted()
                        } else {
                            emmiter.onError(NSError(domain: BASE_URL, code: -1, userInfo: nil))
                        }

                    }
                case .failure(let encodingError):
                    emmiter.onError(encodingError)
                }
            }
            
            return Disposables.create()
        }
    }
    
    static func share(post : Post) {
        if let topViewController = UIApplication.topViewController() {
            let shareText = "Post by \(post.user?.fullName ?? "")\n\(post.productInfo)\nJoin Cell.Exchange for more details.\nhttp://cell.exchange/product/detail/\(post.id)"
            let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = topViewController.view
            topViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    
    
}
