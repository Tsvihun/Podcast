//
//  MainTabBarController.swift
//  Podcast
//
//  Created by Tsvigun on 27.09.2021.
//

import UIKit

class MainTabBarController: UITabBarController {
  
  // MARK: - Properties
  
  var maximazedTopAnchorConstraint: NSLayoutConstraint!
  var minimazedTopAnchorConstraint: NSLayoutConstraint!
  var bottomAnchorConstraint: NSLayoutConstraint!
  let PlayerDetailView = PlayerDetailsView.initFromNib()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    UINavigationBar.appearance().prefersLargeTitles = true
    tabBar.tintColor = .purple
    
    
    setupViewControllers()
    
    setupPlayerDetailsView()
    
    //perform(#selector(maximazePlayerDetails), with: nil, afterDelay: 1)
    
  }
  
  // MARK: - Setup Functions
  
  private func setupViewControllers() {
    let layout = UICollectionViewFlowLayout()
    let FavoritesController = FavoritesController(collectionViewLayout: layout)
    viewControllers = [
      generateNavigationController(for: PodcastsSearchController(), title: "Search", image: #imageLiteral(resourceName: "search")),
      generateNavigationController(for: FavoritesController, title: "Favorites", image: #imageLiteral(resourceName: "favorites")),
      generateNavigationController(for: DownloadsController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
    ]
  }
  
  private func setupPlayerDetailsView() {
    
    view.insertSubview(PlayerDetailView, belowSubview: tabBar)
    
    PlayerDetailView.translatesAutoresizingMaskIntoConstraints = false // enables auto layout
    
    maximazedTopAnchorConstraint = PlayerDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
    maximazedTopAnchorConstraint.isActive = true
    minimazedTopAnchorConstraint = PlayerDetailView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
    //minimazedTopAnchorConstraint.isActive = true
    bottomAnchorConstraint = PlayerDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
    bottomAnchorConstraint.isActive = true
    
    PlayerDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    PlayerDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    
  }
  
  // MARK: - Helper Functions
  
  private func generateNavigationController(for rootViewCotroller: UIViewController, title: String, image: UIImage) -> UIViewController {
    
    let navController = UINavigationController(rootViewController: rootViewCotroller)
    
    rootViewCotroller.navigationItem.title = title
    
    navController.tabBarItem.title = title
    navController.tabBarItem.image = image
    
    return navController
  }
  
  // MARK: - Selectors
  
  func minimazePlayerDetails() {
    
    maximazedTopAnchorConstraint.isActive = false
    bottomAnchorConstraint.constant = view.frame.height
    minimazedTopAnchorConstraint.isActive = true
    
    PlayerDetailView.miniPlayerView.alpha = 1
    PlayerDetailView.maximazedStackView.alpha = 0
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.view.layoutIfNeeded()
    })
  }
  
  func maximazePlayerDetails(episode: Episode?, playlistEpisodes: [Episode] = []) {
    
    if episode != nil { PlayerDetailView.episode = episode }
    PlayerDetailView.playlistEpisode = playlistEpisodes
    
    minimazedTopAnchorConstraint.isActive = false
    maximazedTopAnchorConstraint.isActive = true
    maximazedTopAnchorConstraint.constant = 0
    bottomAnchorConstraint.constant = 0
    
    PlayerDetailView.miniPlayerView.alpha = 0
    PlayerDetailView.maximazedStackView.alpha = 1
    
    PlayerDetailView.playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
    PlayerDetailView.miniPlayPauseButton.setImage(UIImage(named: "pause"), for: .normal)
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      self.view.layoutIfNeeded()
      self.tabBar.frame.origin.y = self.view.frame.height
    })
  }
  
}
