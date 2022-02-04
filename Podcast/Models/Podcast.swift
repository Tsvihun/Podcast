//
//  Podcast.swift
//  Podcast
//
//  Created by Tsvigun on 27.09.2021.
//

import Foundation

class Podcast: NSObject, Decodable, NSCoding {
  
  // MARK: - Properties
  
  var trackName: String?
  var artistName: String?
  var artworkUrl600: String?
  var trackCount: Int?
  var feedUrl: String?
  
  // MARK: - NSCoding
  
  func encode(with coder: NSCoder) {
    print("DEBUG: Trying to transform Podcast into Data")
    
    coder.encode(trackName ?? "", forKey: "trackNameKey")
    coder.encode(artistName ?? "", forKey: "artistNameKey")
    coder.encode(artworkUrl600 ?? "", forKey: "artworkKey")
    coder.encode(feedUrl ?? "", forKey: "feedKey")
    
  }
  
  required init?(coder: NSCoder) {
    print("DEBUG: Trying to turn Data into Podcast")
    
    self.trackName = coder.decodeObject(forKey: "trackNameKey") as? String
    self.artistName = coder.decodeObject(forKey: "artistNameKey") as? String
    self.artworkUrl600 = coder.decodeObject(forKey: "artworkKey") as? String
    self.feedUrl = coder.decodeObject(forKey: "feedKey") as? String
  }
  
}


