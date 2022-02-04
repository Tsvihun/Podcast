//
//  RSSFeed.swift
//  Podcast
//
//  Created by Tsvigun on 29.09.2021.
//

import FeedKit

extension RSSFeed {
  
  func  toEpisodes() -> [Episode] {
    
    let imageURL = iTunes?.iTunesImage?.attributes?.href
    var episodes = [Episode]()
    
    items?.forEach({ (feedItem) in
      
      var episode = Episode(feedItem: feedItem)
      if episode.imageUrl == nil { episode.imageUrl = imageURL }
      episodes.append(episode)
      
    })
    
    return episodes
  }
  
}
