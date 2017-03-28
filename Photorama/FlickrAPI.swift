//
//  FlickrAPI.swift
//  Photorama
//
//  Created by seo on 2017. 3. 27..
//  Copyright © 2017년 seoju. All rights reserved.
//

import Foundation
import SwiftyJSON

enum Method: String {
    case RecentPhotos = "flickr.photos.getRecent"
}

enum PhotosResult {
    case Success([Photo])
    case Failure(Error)
}

enum FlickrError: Error {
    case InvalidJSONData
}

struct FlickrAPI {
    private static let baseURLString = "https://api.flickr.com/services/rest"
    private static let APIkey = "a6d819499131071f158fd740860a5a88"
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    
    // Swifty JSON
    private static func photoFromJSON(json: JSON) -> Photo? {
        guard let photoID = json["id"].string,
            let title = json["title"].string,
            let dateString = json["datetaken"].string,
            let photoURLString = json["url_h"].string,
            let url = URL(string: photoURLString),
            let dateTaken = dateFormatter.date(from: dateString) else {
                // Photo를 생성하기에 정보가 충분하지 않다.
                return nil
        }
        return Photo(title: title.description, photoID: photoID.description, remoteURL: url, dateTaken: dateTaken)
    }
    
    private static func photoFromJSONObject(json: [String:AnyObject]) -> Photo? {
        guard let photoID = json["id"] as? String,
            let title = json["title"] as? String,
            let dateString = json["datetaken"] as? String,
            let photoURLString = json["url_h"] as? String,
            let url = URL(string: photoURLString),
            let dateTaken = dateFormatter.date(from: dateString) else {
                // Photo를 생성하기에 정보가 충분하지 않다.
                return nil
        }
        return Photo(title: title, photoID: photoID, remoteURL: url, dateTaken: dateTaken)
    }
    
    private static func flickrURL(method: Method, parameters: [String:String]?) -> URL {
        
        let componets = NSURLComponents(string: baseURLString)!
        var queryItems = [NSURLQueryItem]()
        
        let baseParams = [
            "method": method.rawValue,
            "format":"json",
            "nojsoncallback":"1",
            "api_key": APIkey]
        
        for (key, value) in baseParams {
            let item = NSURLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = NSURLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        componets.queryItems = queryItems as [URLQueryItem]?
        
        return componets.url!
    }
    
    static func recentPhotosURL() -> URL {
        return flickrURL(method: .RecentPhotos, parameters: ["extras":"url_h,date_taken"])
    }
    
    // MARK : JSON 데이터 파싱
    static func photosFromJSONData(data: Data) -> PhotosResult {
        // SwitfyJSON
        let json = JSON(data: data)
        switch json.type {
        case .array:
            print("json array")
        case .dictionary:
            guard let photos = json.dictionaryValue["photos"],
                let photosArray = photos.dictionaryValue["photo"] else {
                // 일치하는 JSON 구조체가 없다.
                return .Failure(FlickrError.InvalidJSONData)
            }
            
            var finalPhotos = [Photo]()
            
            // JSON형식으로만 넘겨준다.
            for photoJSON in photosArray {
                if let photo = photoFromJSON(json: photoJSON.1) {
                    finalPhotos.append(photo)
                }
            }
            
            if finalPhotos.count == 0 && photosArray.count > 0 {
                // phots에서 아무것도 파싱할 수 없다.
                // photos의 JSON 포맷이 바뀌었을 수도 있다.
                return .Failure(FlickrError.InvalidJSONData)
            }
            
            return .Success(finalPhotos)
            
        default:
            break
        }
        return .Failure(json.error!)
        // 기존 방식
//        do {
//            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
//            
//            guard let jsonDictionary = jsonObject as? [String:AnyObject],
//                let photos = jsonDictionary["photos"] as? [String:AnyObject],
//                let photosArray = photos["photo"] as? [[String:AnyObject]] else {
//                    // 일치하는 JSON 구조체가 없다.
//                    return .Failure(FlickrError.InvalidJSONData)
//            }
//            
//            var finalPhotos = [Photo]()
//            
//            for photoJSON in photosArray {
//                if let photo = photoFromJSONObject(json: photoJSON) {
//                    finalPhotos.append(photo)
//                }
//            }
//            
//            if finalPhotos.count == 0 && photosArray.count > 0 {
//                // phots에서 아무것도 파싱할 수 없다.
//                // photos의 JSON 포맷이 바뀌었을 수도 있다.
//                return .Failure(FlickrError.InvalidJSONData)
//            }
//            
//            return .Success(finalPhotos)
//        } catch let error {
//            return .Failure(error)
//        }
    }
}
