//
//  TrendincCell.swift
//  Youtube
//
//  Created by LeeChan on 10/7/16.
//  Copyright © 2016 MarkiiimarK. All rights reserved.
//

import UIKit

class TrendingCell: FeedCell {
    
    override func fetchVideos() {
            
        APIService.sharedInstance.fetchTrendingVideo { (videos: [Video]) in
                
            self.videos = videos
            self.collectionView.reloadData()
        }
    }
}
