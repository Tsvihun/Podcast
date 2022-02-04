//
//  EpisodeCell.swift
//  Podcast
//
//  Created by Tsvigun on 29.09.2021.
//

import UIKit
import SDWebImage

class EpisodeCell: UITableViewCell {

  @IBOutlet weak var episodeImageView: UIImageView!
  @IBOutlet weak var pubDateLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var progressLabel: UILabel!
  
  var episode: Episode! {
    didSet {
      titleLabel.text = episode.title
      descriptionLabel.text = episode.desription
      
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MMM dd, yyyy"
      pubDateLabel.text = dateFormatter.string(from: episode.pubDate)
      
      let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
      
      
      episodeImageView.sd_setImage(with: url, completed: nil)
    }
  }
}
