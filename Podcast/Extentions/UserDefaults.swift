//
//  UserDefaults.swift
//  Podcast
//
//  Created by Tsvigun on 14.10.2021.
//

import Foundation
import UIKit

extension UserDefaults {
  
  // MARK: - Properties
  
  static let favoritedPodcastKey = "favoritedPodcastKey"
  static let downloadedEpisodesKey = "downloadedEpisodesKey"
  
  
  // MARK: - Metods for Podcasts
  
  func savedPodcasts() -> [Podcast] {
    guard let savedPodcastsData = data(forKey: UserDefaults.favoritedPodcastKey) else { return [] }
    guard let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: savedPodcastsData) as? [Podcast] else { return [] }
    return savedPodcasts
  }
  
  func deletePodcast(podcast: Podcast) {
    
    let filtered = savedPodcasts().filter { $0.artworkUrl600 != podcast.artworkUrl600 && $0.trackName != podcast.trackName }
  
    do {
      let data = try NSKeyedArchiver.archivedData(withRootObject: filtered, requiringSecureCoding: false)
      UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
    } catch let error {
      print("DEBUG: Erorr transform Podcast into Data:", error.localizedDescription)
    }
    
  }
  
  func downloadEpisode(episode: Episode) {
    
    do {
      var downloadedEpisodes = downloadedEpisodes()
      downloadedEpisodes.insert(episode, at: 0)
      
      let data = try JSONEncoder().encode(downloadedEpisodes)
      UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
    } catch let encodeError {
      print("DEBUG: Failed to encode episode:", encodeError.localizedDescription)
    }
  }
  
  func deleteEpisode(episode: Episode) {
    do {
      let filtered = downloadedEpisodes().filter { $0.streamUrl != episode.streamUrl }
      
      let data = try JSONEncoder().encode(filtered)
      UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
    } catch let encodeError {
      print("DEBUG: Failed to encode episode:", encodeError.localizedDescription)
    }
  }
  
  func downloadedEpisodes() -> [Episode] {
    guard let episodesData = data(forKey: UserDefaults.downloadedEpisodesKey) else { return [] }
    do {
      let episodes = try JSONDecoder().decode([Episode].self, from: episodesData)
      return episodes
    } catch let decodeError {
      print("DEBUG: Failed to decode episode:", decodeError.localizedDescription)
    }
    return []
  }
  
}
