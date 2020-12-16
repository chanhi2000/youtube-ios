//
//  SubscriptionCell.swift
//  Youtube
//
//  Created by LeeChan on 10/7/16.
//  Copyright © 2016 MarkiiimarK. All rights reserved.
//

import UIKit

class SubscriptionCell: FeedCell {
    
    override func fetchVideos() {
        
        APIService.sharedInstance.fetchSubscriptionVideo { (videos: [Video]) in
            
            self.videos = videos
            self.collectionView.reloadData()
        }
    }

}
