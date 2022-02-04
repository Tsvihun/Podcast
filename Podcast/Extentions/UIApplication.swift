//
//  UIApplication.swift
//  Podcast
//
//  Created by Tsvigun on 10.10.2021.
//

import UIKit

extension UIApplication {
  static func MainTabBarController() -> MainTabBarController? {
    return shared.windows.filter { $0.isKeyWindow }.first?.rootViewController as? MainTabBarController
  }
}
