//
//  PodcastsSearchController.swift
//  Podcast
//
//  Created by Tsvigun on 27.09.2021.
//

import UIKit

class PodcastsSearchController: UITableViewController {
  
  // MARK: - Properties
  
  private let reuseIdentifier = "reuseIdentifier"
  
  var timer: Timer?
  
  var podcasts = [Podcast]()
  
  let searchController = UISearchController(searchResultsController: nil)
  
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
    setupTableView()
    setupSearchBar()
    searchBar(searchController.searchBar, textDidChange: "2022")
    
    if #available(iOS 15.0, *) {
        UITableView.appearance().sectionHeaderTopPadding = CGFloat(0)
    }
  }
  
  // MARK: - Helper Functions
  
  private func setupTableView() {
    //    tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    tableView.tableFooterView = UIView()
    let nib = UINib(nibName: "PodcastCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
  }
  
  private func setupSearchBar() {
    definesPresentationContext = true
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
  }
}

// MARK: - UITableViewDelegate/DataSourse

extension PodcastsSearchController {
  
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let podcastSearchView = Bundle.main.loadNibNamed("PodcastsSearchingView", owner: self, options: nil)?.first as? UIView
    return podcastSearchView
  }
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return podcasts.isEmpty && searchController.searchBar.text?.isEmpty == false ? 250 : 0
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let label = UILabel()
    label.text = "No results, please enter a search query."
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
    label.textColor = .purple
    return label
  }
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return podcasts.isEmpty && searchController.searchBar.text?.isEmpty == true ? 250 : 0
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return podcasts.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! PodcastCell
    
    cell.podcast = podcasts[indexPath.row]
    
    //    cell.imageView?.image = UIImage(named: "appicon")
    //    cell.textLabel?.text = "\(podcasts[indexPath.row].trackName ?? "")\n\(podcasts[indexPath.row].artistName ?? "")"
    //    cell.textLabel?.numberOfLines = -1
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 132
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let episodesController = EpisodesController()
    episodesController.podcast = podcasts[indexPath.row]
    navigationController?.pushViewController(episodesController, animated: true)
  }
  
}

// MARK: - UISearchBarDelegate

extension PodcastsSearchController: UISearchBarDelegate {
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    print("DEBUG: Searching:", searchText)
    
    podcasts = []          // setup view for
    tableView.reloadData() // footer here, when text did change
    
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
      Service.shared.fetchPodcasts(searchText: searchText, completionHandler: { (podcasts) in
        self.podcasts = podcasts
        self.tableView.reloadData()
      })
    })
  }
  
}
