//
//  File.swift
//  Youtube
//
//  Created by LeeChan on 9/29/16.
//  Copyright © 2016 MarkiiimarK. All rights reserved.
//

import UIKit

class APIService: NSObject {
    
    static let sharedInstance = APIService()
    
    let baseUrl = "https://s3-us-west-2.amazonaws.com/youtubeassets"
    
    func fetchVideo(completion: @escaping ([Video]) -> ()) {
        fetchFeedForUrlString(urlString: "\(baseUrl)/home.json", completion: completion)
    }

    
    func fetchTrendingVideo(completion: @escaping ([Video]) -> ()) {
        fetchFeedForUrlString(urlString: "\(baseUrl)/trending.json", completion: completion)
        
    }
    
    func fetchSubscriptionVideo(completion: @escaping ([Video]) -> ()) {
        fetchFeedForUrlString(urlString: "\(baseUrl)/subscriptions.json", completion: completion)
        
    }
    
    func fetchFeedForUrlString(urlString: String, completion: @escaping ([Video]) -> ()) {
        
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if error != nil {
                #if DEBUG
                    print("DEBUG: - APIService:fetchFeedForUrlString:URLSession:error\n\(String(describing:error))\n")
                #endif
                return
            }
            
            do {
                if let unwrappedData = data, let jsonDictionaries = try JSONSerialization.jsonObject(with: unwrappedData, options: .mutableContainers) as? [[String: AnyObject]] {
//                    let videos = jsonDictionaries.map({  return Video(dictionary: $0)  })
                    DispatchQueue.main.async(execute: {
                        completion(jsonDictionaries.map({  return Video(dictionary: $0)  }))
                    })
                }
            
            } catch let jsonError {
                #if DEBUG
                    print("DEBUG: - APIService:fetchFeedForUrlString:URLSession:jsonError\n\(String(describing:jsonError))\n" )
                #endif
            }
            
            
            }.resume()
    
    }

}
//
//let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
//
//var videos = [Video]()
//
//for dictionary in json as! [[String: AnyObject]] {
//    let video = Video()
//    video.title = dictionary["title"] as? String
//    video.thumbnailImageName = dictionary["thumbnail_image_name"] as? String
//    
//    let channelDictionary = dictionary["channel"] as? [String: AnyObject]
//    let channel = Channel()
//    channel.name = channelDictionary?["name"] as? String
//    channel.profileImageName = channelDictionary?["profile_image_name"] as? String
//    
//    video.channel = channel
//    
//    videos.append(video)
//}
//
//DispatchQueue.main.async(execute: {
//    completion(videos)
//})
