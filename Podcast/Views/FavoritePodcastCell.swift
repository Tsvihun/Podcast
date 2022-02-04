//
//  FavoritePodcastCell.swift
//  Podcast
//
//  Created by Tsvigun on 14.10.2021.
//

import UIKit
import SDWebImage

class FavoritePodcastCell: UICollectionViewCell {
  
  // MARK: - Properties
  
  var podcast: Podcast! {
    didSet {
      nameLabel.text = podcast.trackName
      artistNameLabel.text = podcast.artistName
      
      let url = URL(string: podcast.artworkUrl600?.toSecureHTTPS() ?? "")
      
      imageView.sd_setImage(with: url, completed: nil)
    }
  }
  
  let imageView: UIImageView = {
    let image = UIImageView()
    image.image = #imageLiteral(resourceName: "appicon")
    return image
  }()
  
  let nameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
    label.text = "Podcast Name"
    return label
  }()
  
  let artistNameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14)
    label.textColor = .lightGray
    label.text = "Artist Name"
    return label
  }()
  
  // MARK: - Lifecycle
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Helper Functions
  
  private func setupViews() {
    
    let stackView = UIStackView(arrangedSubviews: [imageView, nameLabel, artistNameLabel])
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(stackView)
    imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
    stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
  }
  
}
