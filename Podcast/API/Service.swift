//
//  Service.swift
//  Podcast
//
//  Created by Tsvigun on 28.09.2021.
//

import Foundation
import Alamofire
import FeedKit

struct SearchResults: Decodable {
  let resultCount: Int
  let results: [Podcast]
}

extension Notification.Name {
  static let downloadProgress  = NSNotification.Name("downloadProgress")
  static let downloadComplete  = NSNotification.Name("downloadComplete")
}

class Service {
  
  let baseiTunesSearchURL = "https://itunes.apple.com/search"
  typealias EpisodeDownloadCompleteTuple = (fileUrl: String, episodeTitle:String)
  
  static let shared = Service() // singleton
  
  func fetchPodcasts(searchText: String, completionHandler: @escaping([Podcast]) -> ()) {
    
    // Implementing Alomafire to search iTunes API
    let parameters = ["term": searchText, "media": "podcast"]
    
    AF.request(baseiTunesSearchURL,
               method: .get,
               parameters: parameters,
               encoding: URLEncoding.default).responseData(completionHandler: { (dataResponse) in
      
      if let error = dataResponse.error {
        print("DEBUG: Failed response:", error.localizedDescription)
        return
      }
      guard let data = dataResponse.data else { return }
      
      do {
        let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
        completionHandler(searchResult.results)
      } catch let decodeErr {
        print("DEBUG: Failed to decode:", decodeErr.localizedDescription)
      }
      
    })
  }
  
  func fetchEpisodes(feedUrl: String, completionHandler: @escaping([Episode]) -> ()) {
    
    guard let url = URL(string: feedUrl.toSecureHTTPS() ) else { return }
    
    let parser = FeedParser(URL: url)
    
    parser.parseAsync(result: { (result) in
      
      switch result {
        
      case .success(let feed):
        guard let feed = feed.rssFeed else { return }
        let episodes = feed.toEpisodes()
        completionHandler(episodes)
        
      case .failure(let error):
        print("DEBUG: Fetch episodes error:", error.localizedDescription)
        
      }
    })
  }
  
  func downloadEpisode(episode: Episode) {
    print("DEBUG: Downloading episode using Alamofire")
    
    let downloadRequest = DownloadRequest.suggestedDownloadDestination()
    AF.download(episode.streamUrl, interceptor: nil, to: downloadRequest).downloadProgress(closure: { (progress) in
      print("DEBUG:", progress.fractionCompleted)
      
      // notify DownloadController about download progress
      NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["title" : episode.title, "progress" : progress.fractionCompleted])
     
    }).response(completionHandler: { (response) in
      guard let fileUrl = response.fileURL?.absoluteString else { return }
      print("DEBUG:", fileUrl)
      
      // notify DownloadController about download complete
      let episodeDownloadComplete = EpisodeDownloadCompleteTuple(fileUrl, episode.title)
      NotificationCenter.default.post(name: .downloadComplete, object: episodeDownloadComplete, userInfo: nil)
       
      
      // update UserDefaults downloaded episodes with this temp file
      
      var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
      guard let index = downloadedEpisodes.firstIndex(where: { $0.title == episode.title } ) else { return }
      downloadedEpisodes[index].fileUrl = fileUrl
      
      do {
        let data = try JSONEncoder().encode(downloadedEpisodes)
        UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
      } catch let encodeError {
        print("DEBUG: Failed to encode episode:", encodeError.localizedDescription)
      }
    })
  }
  
}
