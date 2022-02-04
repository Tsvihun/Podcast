//
//  Episode.swift
//  Podcast
//
//  Created by Tsvigun on 29.09.2021.
//

import Foundation
import FeedKit

struct Episode: Encodable, Decodable {
  let title: String
  let author: String
  let pubDate: Date
  let desription: String
  var imageUrl: String?
  var fileUrl: String?
  let streamUrl: String
  
  init(feedItem: RSSFeedItem) {
    self.title = feedItem.title ?? ""
    self.author = feedItem.iTunes?.iTunesAuthor ?? ""
    self.pubDate = feedItem.pubDate ?? Date()
    self.desription = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
    self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
    self.streamUrl = feedItem.enclosure?.attributes?.url ?? ""
  }
}
