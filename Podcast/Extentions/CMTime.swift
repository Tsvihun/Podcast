//
//  CMTime.swift
//  Podcast
//
//  Created by Tsvigun on 06.10.2021.
//

import AVKit

extension CMTime {
  
  func toDisplayString() -> String {
    
    if CMTimeGetSeconds(self).isNaN {
      return "--:--"
    }

    let totalSeconds = Int(CMTimeGetSeconds(self))
    let seconds = totalSeconds % 60
    let minutes = totalSeconds / 60
    let timeFormatString = String(format: "%02d:%02d", minutes, seconds)
    return timeFormatString
    
  }
}
