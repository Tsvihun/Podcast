//
//  ViewController.swift
//  Podcast
//
//  Created by Tsvigun on 27.09.2021.
//

import UIKit

class DownloadsController: UITableViewController {
  
  // MARK: - Properties
  
  private let reuseIdentifier = "reuseIdentifier"
  private var episodes = UserDefaults.standard.downloadedEpisodes()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    setupTableView()
    setupObservers()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    episodes = UserDefaults.standard.downloadedEpisodes()
    tableView.reloadData()
  }
  
  // MARK: - Helper Functions
  
  private func setupTableView() {
    let nib = UINib(nibName: "EpisodeCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
    tableView.tableFooterView = UIView()
  }
  
  private func setupObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadComplete), name: .downloadComplete, object: nil)
  }
  
  // MARK: - Selectors
  
  @objc private func handleDownloadProgress(notification: Notification) {
    guard let userInfo = notification.userInfo as? [String: Any] else { return }
    guard let progress = userInfo["progress"] as? Double else { return }
    guard let title = userInfo["title"] as? String else { return }
  
    // lets find index using title
    guard let index = self.episodes.firstIndex(where: { $0.title == title }) else { return }
    guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else { return }
    cell.progressLabel.isHidden = false
    cell.progressLabel.text = "\(Int(progress * 100))%"
    
    if progress == 1 {
      cell.progressLabel.isHidden = true
    }
  }
  
  @objc private func handleDownloadComplete(notification: Notification) {
    guard let episodeDownloadComplete = notification.object as? Service.EpisodeDownloadCompleteTuple else { return }
    
    // lets find index using title
    guard let index = self.episodes.firstIndex(where: { $0.title == episodeDownloadComplete.episodeTitle }) else { return }
    self.episodes[index].fileUrl = episodeDownloadComplete.fileUrl
  }
  
  // MARK: - UITableView
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return episodes.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 132
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! EpisodeCell
    cell.episode = episodes[indexPath.row]
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("DEBUG: Launch episode player")
    let episode = episodes[indexPath.row]
    
    if episode.fileUrl != nil {
    UIApplication.MainTabBarController()?.maximazePlayerDetails(episode: episode, playlistEpisodes: episodes)
    } else {
      let alertController = UIAlertController(title: "File URL not found",
                                              message: "Cannot find local file, play using stream url instead",
                                              preferredStyle: .actionSheet)
      alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
        UIApplication.MainTabBarController()?.maximazePlayerDetails(episode: episode, playlistEpisodes: self.episodes)
      }))
      alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
      present(alertController, animated: true)
    }
  }
  
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler : { (_, indexPath) in
      print("DEBUG: Delete episode from UserDefaults and tableView")
      // delete episode from UserDefaults
      UserDefaults.standard.deleteEpisode(episode: self.episodes[indexPath.row])
      // delete episode from tableView
      self.episodes = UserDefaults.standard.downloadedEpisodes()
      self.tableView.deleteRows(at: [indexPath], with: .fade)
    })
    return [deleteAction]
  }
  
}
