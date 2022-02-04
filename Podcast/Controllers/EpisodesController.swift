//
//  EpisodesController.swift
//  Podcast
//
//  Created by Tsvigun on 29.09.2021.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {
  
  // MARK: - Properties
  
  private let reuseIdentifier = "reuseIdentifier"
  private var episodes = [Episode]()
  
  var podcast: Podcast? {
    didSet {
      navigationItem.title = podcast?.trackName
      fetchEpisodes()
    }
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    setupNavigationBarButtons()
  }
  
  // MARK: - Helper Functions
  
  private func setupTableView() {
    let nib = UINib(nibName: "EpisodeCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
    tableView.tableFooterView = UIView()
  }
  
  private func fetchEpisodes() {
    guard let feedUrl = podcast?.feedUrl else { return }
    Service.shared.fetchEpisodes(feedUrl: feedUrl, completionHandler: { (episodes) in
      self.episodes = episodes
      DispatchQueue.main.async { self.tableView.reloadData() }
    })
  }
  
  private func setupNavigationBarButtons() {
    
    // let's check if we have already saved this podcast as favorited
    let savedPodcasts = UserDefaults.standard.savedPodcasts()
    
    let hasFavorited = savedPodcasts.firstIndex(where: { $0.trackName == self.podcast?.trackName && $0.artistName == self.podcast?.artistName }) != nil
    
    if hasFavorited {
      // setting up Heart icon
      navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "heart"), style: .plain , target: self, action: nil)
    } else {
      // setting up Favorite button
      navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorite))
    }
    
  }
  
  private func showBadgeHightlight() {
    UIApplication.MainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = "New"
  }
  
  // MARK: - Selectors
  
  @objc private func handleSaveFavorite() {
    print("DEBUG: Saving info into UserDefaults")
    
    guard let podcast = self.podcast else { return }
    
    // 1. check and fetch our saved podcasts first
    var listOfPodcasts = UserDefaults.standard.savedPodcasts()
    // 2. Add selected podcast into saved podcasts
    listOfPodcasts.append(podcast)
    // 3. Transform [Podcast] into Data
    do {
      let data = try NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts, requiringSecureCoding: false)
      UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
      showBadgeHightlight()
      navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "heart"), style: .plain , target: self, action: nil)
    } catch let error {
      print("DEBUG: Erorr transform Podcast into Data:", error.localizedDescription)
    }
    
  }
  
}

// MARK: - UITableViewDelegate/DataSourse

extension EpisodesController {
  
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    
    let activityIndicatorView = UIActivityIndicatorView(style: .large)
    activityIndicatorView.color = .darkGray
    episodes.isEmpty ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
    return activityIndicatorView
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return episodes.isEmpty ? 200 : 0
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return episodes.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! EpisodeCell
    
    cell.episode = episodes[indexPath.row]
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 132
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let mainTabBarController = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController as? MainTabBarController
    mainTabBarController?.maximazePlayerDetails(episode: episodes[indexPath.row], playlistEpisodes: self.episodes)
    //    let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
    //    let playerDetailsView = PlayerDetailsView.initFromNib()
    //    playerDetailsView.frame = self.view.frame
    //    window?.addSubview(playerDetailsView)
  }
  
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    
    
    let downloadAction = UITableViewRowAction(style: .normal, title: "Download", handler: { (_, _) in
      print("DEBUG: Attempt Downloading episode into UserDefaults by editActionsRowAt")
      
      let episode = self.episodes[indexPath.row]
      // let's check if we have already saved this episoded as downloaded
      let DownloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
      let hasDownloaded = DownloadedEpisodes.firstIndex(where: { $0.streamUrl == episode.streamUrl }) != nil
      
      if hasDownloaded {
        let alertController = UIAlertController(title: nil, message: "Episode Already Downloaded", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertController, animated: true)
      } else {
        // download the podcast episode into Alamofire
        UserDefaults.standard.downloadEpisode(episode: episode)
        // download the podcast episode.fileUrl using Alamofire
        Service.shared.downloadEpisode(episode: episode)
      }
    })
    return [downloadAction]

  }
  
}
