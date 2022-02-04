//
//  FavoritesController.swift
//  Podcast
//
//  Created by Tsvigun on 14.10.2021.
//

import UIKit

class FavoritesController: UICollectionViewController {
  
  // MARK: - Properties
  
  private let ReuseIdentifier = "ReuseIdentifier"
  private var podcasts = UserDefaults.standard.savedPodcasts()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectionView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    podcasts = UserDefaults.standard.savedPodcasts()
    collectionView.reloadData()
    UIApplication.MainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = nil
  }
  
  // MARK: - Helper Functions
  
  private func setupCollectionView() {
    collectionView.backgroundColor = .white
    collectionView.register(FavoritePodcastCell.self, forCellWithReuseIdentifier: ReuseIdentifier)
    
    let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    collectionView.addGestureRecognizer(gesture)
  }
  
  // MARK: - Selectors
  @objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
    print("DEBUG: Captured Long Press")
    
    let location = gesture.location(in: collectionView)
    guard let SelectedIndexPath = collectionView.indexPathForItem(at: location) else { return }
    
    let UIAC = UIAlertController(title: "Remove Podcast?", message: nil, preferredStyle: .actionSheet)
    UIAC.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
      //remove your favorited podcast from UserDefaults
      UserDefaults.standard.deletePodcast(podcast: self.podcasts[SelectedIndexPath.item])
      
      // remove podcast object from collection view
      self.podcasts = UserDefaults.standard.savedPodcasts()
      self.collectionView.deleteItems(at: [SelectedIndexPath])
    }))
    UIAC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    present(UIAC, animated: true, completion: nil)
    
    
  }
  
}

// MARK: - UICollectionViewDataSource

extension FavoritesController {
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return podcasts.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifier, for: indexPath) as! FavoritePodcastCell
    cell.podcast = podcasts[indexPath.item]
    return cell
  }
}

// MARK: - UICollectionViewDelegate

extension FavoritesController {
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let episodeController = EpisodesController()
    episodeController.podcast = self.podcasts[indexPath.item]
    navigationController?.pushViewController(episodeController, animated: true)
  }
  
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FavoritesController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = (view.frame.width - 3 * 16) / 2
    return CGSize(width: width, height: width + 46)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 16
  }
}
