//
//  Extentions.swift
//  Podcast
//
//  Created by Tsvigun on 29.09.2021.
//

import Foundation

extension String {
  
  func toSecureHTTPS() -> String {
    return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
  }
}
