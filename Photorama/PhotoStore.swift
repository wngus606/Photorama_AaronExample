//
//  PhotoStore.swift
//  Photorama
//
//  Created by seo on 2017. 3. 27..
//  Copyright © 2017년 seoju. All rights reserved.
//

import UIKit
import Alamofire

enum ImageResult {
    case Success(UIImage)
    case Failure(Error)
}

enum PhotoError: Error {
    case ImageCreationError
}

class PhotoStore {
    
    // 기존 방식
//    let session: URLSession = {
//        return URLSession(configuration: URLSessionConfiguration.default)
//    }()
    
    func fetchRecentPhotos(completion: @escaping (PhotosResult) -> Void) {
        let url = FlickrAPI.recentPhotosURL()
        // Alamofire
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).downloadProgress(queue: DispatchQueue.global(qos: .utility), closure: { (progress) in
//            print("Progress: \(progress.fractionCompleted)")
        }).validate({ (request, response, data) -> Request.ValidationResult in
            print("fetchRecentPhotos Success")
            return .success
        }).responseJSON(completionHandler: { (respones) in
            let result = self.processRecentPhotosRequest(data: respones.data, error: respones.error)
            completion(result)
        })
        
        // 기존 방식
//        let request = URLRequest(url: url)
//        let task = session.dataTask(with: request) { (data, response, error) in
//            
//            let result = self.processRecentPhotosRequest(data: data, error: error)
//            
//            completion(result)
//        }
//        task.resume()
    }
    
    func processRecentPhotosRequest(data: Data?, error: Error?) -> PhotosResult {
        guard let jsonData = data else {
            return .Failure(error!)
        }
        
        return FlickrAPI.photosFromJSONData(data: jsonData)
    }
    
    // MARK: Image
    
    func fetchImageForPhoto(photo: Photo, completion: @escaping (ImageResult) -> Void) {
        if let image = photo.image {
            completion(.Success(image))
            return
        }
        
        let photoURL = photo.remoteURL
        
        // Alamofire
        Alamofire.request(photoURL, method: .get).downloadProgress(queue: DispatchQueue.global(qos: .utility), closure: { (progress) in
//            print("Progress: \(progress.fractionCompleted)")
        }).response { (response) in
            let result = self.processImageRequest(data: response.data, error: response.error)
            if case let .Success(image) = result {
                photo.image = image
            }
            completion(result)
        }
        
        // 기존 방식
//        let request = URLRequest(url: photoURL)
//        
//        let task = session.dataTask(with: request) { (data, respons, error) in
//            let result = self.processImageRequest(data: data, error: error)
//            
//            if case let .Success(image) = result {
//                photo.image = image
//            }
//            completion(result)
//        }
//        task.resume()
    }
    
    func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        guard let imageData = data, let image = UIImage(data: imageData) else {
            // 이미지를 만들 수 없다.
            if data == nil {
                return .Failure(error!)
            } else {
                return .Failure(PhotoError.ImageCreationError)
            }
        }
        return .Success(image)
    }
}
