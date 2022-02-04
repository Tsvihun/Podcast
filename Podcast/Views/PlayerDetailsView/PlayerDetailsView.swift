//
//  PlayerDetailsView.swift
//  Podcast
//
//  Created by Tsvigun on 02.10.2021.
//

import UIKit
import SDWebImage
import AVKit
import MediaPlayer
import NotificationCenter

class PlayerDetailsView: UIView {
  
  // MARK: - Properties
  
  var episode: Episode! {
    didSet {
      episodeTitleLabel.text = episode.title
      authorLabel.text = episode.author
      miniTitleLabel.text = episode.title
      setupNowPlayingInfo()
      setupAudioSession()
      playEpisode()
      
      guard let url = URL(string: episode.imageUrl ?? "") else { return }
      episodeImageView.sd_setImage(with: url)
      miniEpisodeImageView.sd_setImage(with: url, completed: { (image, _, _, _) in
        
        let image = self.episodeImageView.image ?? UIImage()
        
        let artwork = MPMediaItemArtwork(boundsSize: .zero, requestHandler: { (size) -> UIImage in
                                          return image })
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
      })
      
    }
  }
  
  var playlistEpisode = [Episode]()
  
  private let player: AVPlayer = {
    let avPlayer = AVPlayer()
    avPlayer.automaticallyWaitsToMinimizeStalling = false
    return avPlayer
  }()
  
  var panGesture: UIPanGestureRecognizer!
  
  
  // MARK: - IB Actions and Outlets of maximazed Player
  
  @IBOutlet weak var maximazedStackView: UIStackView!
  
  @IBAction func handleDismiss(_ sender: Any) {
    //removeFromSuperview()
    print("DEBUG: handleDismiss")
    UIApplication.MainTabBarController()?.minimazePlayerDetails()
    
  }
  
  @IBOutlet weak var playPauseButton: UIButton! {
    didSet {
      playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
      playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
    }
  }
  
  @IBOutlet weak var episodeImageView: UIImageView! {
    didSet {
      episodeImageView.layer.cornerRadius = 5
      episodeImageView.clipsToBounds = true
      episodeImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }
  }
  
  @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
    
    let percentage = currentTimeSlider.value
    guard let duration = player.currentItem?.duration else { return }
    let durationInSeconds = CMTimeGetSeconds(duration)
    let seekTimeInSeconds = Float64(percentage) * durationInSeconds
    let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
    
    //setup Elapsed Time for lockscreen
    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
    
    player.seek(to: seekTime)
    
  }
  
  @IBAction func handleRewind(_ sender: Any) {
    seekToCurrentTime(delta: -15)
    
  }
  
  @IBAction func handleFastForward(_ sender: Any) {
    seekToCurrentTime(delta: 15)
  }
  
  @IBAction func handleVolumeChange(_ sender: UISlider) {
    player.volume = sender.value
  }
  
  
  @IBOutlet weak var episodeTitleLabel: UILabel!
  @IBOutlet weak var authorLabel: UILabel!
  @IBOutlet weak var currentTimeLabel: UILabel!
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var currentTimeSlider: UISlider!
  
  // MARK: - IB Actions and Outlets of minimazed Player
  
  @IBOutlet weak var miniPlayerView: UIView!
  @IBOutlet weak var miniEpisodeImageView: UIImageView!
  @IBOutlet weak var miniTitleLabel: UILabel!
  @IBOutlet weak var miniPlayPauseButton: UIButton! {
    didSet {
      miniPlayPauseButton.setImage(UIImage(named: "pause"), for: .normal)
      miniPlayPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
    }
  }
  
  @IBAction func miniFastForwardButton(_ sender: Any) {
    seekToCurrentTime(delta: 15)
  }
  
  
  // MARK: - Lifecycle
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    observeBoundaryTime()
    observePlayerCurrentTime()
    setupGestures()
    setupRemoteControl()
    setupInterruptionObserver()
    
  }
  
  deinit {
    print("DEBUG: PlayerDetailsView memory being reclaimed...")
  }
  
  // MARK: - Helper Functions
  static func initFromNib() -> PlayerDetailsView {
    return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
  }
  
  private func setupGestures() {
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximaze)))
    
    panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    
    miniPlayerView.addGestureRecognizer(panGesture)
    maximazedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
  }
  
  private func playEpisode() {
    
    if episode.fileUrl != nil {
      playEpisodeUsingFileUrl()
    } else {
      playEpisodeUsingStreamUrl()
    }
  }
  
  private func playEpisodeUsingFileUrl() {
    guard let fileUrl = episode.fileUrl else { return }
    guard let url = URL(string: fileUrl) else { return }
    
    let fileName = url.lastPathComponent
    guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    trueLocation.appendPathComponent(fileName)
    
    print("DEBUG: Attempt to play episode from fileUrl", trueLocation)
    
    let playerItem = AVPlayerItem(url: trueLocation)
    player.replaceCurrentItem(with: playerItem)
    player.play()
  }
  
  private func playEpisodeUsingStreamUrl() {
    
    print("DEBUG: Attempt to play episode from streamUrl", episode.streamUrl)
    guard let url = URL(string: episode.streamUrl) else { return }
    let playerItem = AVPlayerItem(url: url)
    player.replaceCurrentItem(with: playerItem)
    player.play()
  }
  
  private func observePlayerCurrentTime() {
    let interval = CMTimeMake(value: 1, timescale: 2) // half a second
    player.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] (time) in
      
      self?.currentTimeLabel.text = time.toDisplayString()
      
      let durationTime = self?.player.currentItem?.duration
      self?.durationLabel.text = durationTime?.toDisplayString()
      
      self?.updateCurrentTimeSlider()
    })
  }
  
  private func observeBoundaryTime() {
    let time = CMTimeMake(value: 1, timescale: 3)
    let times = [NSValue(time: time)]
    player.addBoundaryTimeObserver(forTimes: times, queue: .main, using: { [weak self] in
      print("DEBUG: Episode started playing")
      self?.enlargeEpisodeImageView()
      self?.observeLocksreenDuration()
    })
  }
  
  private func enlargeEpisodeImageView () {
    UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5,
                   initialSpringVelocity: 1, options: .curveEaseOut,
                   animations: { self.episodeImageView.transform = .identity })
  }
  
  private func shrinkEpisodeImageView() {
    UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5,
                   initialSpringVelocity: 1, options: .curveEaseOut,
                   animations: {self.episodeImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7) })
  }
  
  private func updateCurrentTimeSlider() {
    
    let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
    let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
    let percentage = currentTimeSeconds / durationSeconds
    
    currentTimeSlider.value = Float(percentage)
    
  }
  
  private func seekToCurrentTime(delta: Int64) {
    let seekTime = CMTimeAdd(player.currentTime(), CMTimeMake(value: delta, timescale: 1))
    player.seek(to: seekTime)
  }
  
  private func handlePanChanged(gesture: UIPanGestureRecognizer) {
    print("DEBUG: Changed")
    let translation = gesture.translation(in: superview)
    
    transform = CGAffineTransform(translationX: 0, y: translation.y)
    miniPlayerView.alpha = 1 + translation.y / 200
    maximazedStackView.alpha = -translation.y / 200
  }
  
  private func handlePanEnded(gesture: UIPanGestureRecognizer) {
    print("DEBUG: Ended")
    let translation = gesture.translation(in: superview)
    let velocity = gesture.velocity(in: superview)
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      
      self.transform = .identity
      
      if translation.y < -200 || velocity.y < -500 {
        UIApplication.MainTabBarController()?.maximazePlayerDetails(episode: nil)
      } else {
        self.miniPlayerView.alpha = 1
        self.maximazedStackView.alpha = 0
      }
      
    })
  }
  
  private func handleDismissalPanChanged(gesture: UIPanGestureRecognizer) {
    print("DEBUG: Changed")
    let translation = gesture.translation(in: superview)
    maximazedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
  }
  
  private func handleDismissalPanEnded(gesture: UIPanGestureRecognizer) {
    print("DEBUG: Ended")
    let translation = gesture.translation(in: superview)
    let velocity = gesture.velocity(in: superview)
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      
      self.maximazedStackView.transform = .identity
      
      if translation.y > 50 || velocity.y > 500 {
        UIApplication.MainTabBarController()?.minimazePlayerDetails()
      } else {
        self.miniPlayerView.alpha = 0
        self.maximazedStackView.alpha = 1
      }
      
    })
  }
  
  private func setupAudioSession() {
    // before that you need to set in project "TARGETS -> Signing & Capabilities -> Background Modes -> Audio, AirPlay, and Picture in Picture"
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
      try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
    } catch let sessionError {
      print("DEBUG: Failed to activate session:", sessionError)
    }
  }
  
  private func setupRemoteControl() {
    
    let commandCenter = MPRemoteCommandCenter.shared()
    UIApplication.shared.beginReceivingRemoteControlEvents()
    
    commandCenter.playCommand.isEnabled = true
    commandCenter.playCommand.addTarget(handler: { _ in
      self.player.play()
      self.setupElapsedTime(playbackRate: 1)
      self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
      self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
      
      return .success
    })
    
    commandCenter.pauseCommand.isEnabled = true
    commandCenter.pauseCommand.addTarget(handler: { _ in
      self.player.pause()
      self.setupElapsedTime(playbackRate: 0)
      self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
      self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
      
      return .success
    })
    // for button in headphones
    commandCenter.togglePlayPauseCommand.isEnabled = true
    commandCenter.togglePlayPauseCommand.addTarget(handler: { _ in
      self.handlePlayPause()
      return .success
    })
    //next track button
    commandCenter.nextTrackCommand.addTarget(handler: { _ in
      self.handleNextTrack()
      return.success
    })
    //previous track button
    commandCenter.previousTrackCommand.addTarget(handler: { _ in
      self.handlePreviousTrack()
      return.success
    })
  }
  
  private func setupNowPlayingInfo() {
    var nowPlayingInfo = [String : Any]()
    
    nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
    nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
    
    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
  }
  
  private func handleNextTrack() {
    
    if playlistEpisode.count == 0 { return }
    
    let currentEpisodeIndex = playlistEpisode.firstIndex(where: { (ep) in
      return self.episode.title == ep.title && self.episode.author == ep.author
    })
    guard let index = currentEpisodeIndex else { return }
    
    let nextEpisode: Episode
    
    if index == playlistEpisode.count - 1 {
      nextEpisode = playlistEpisode[0]
    } else {
      nextEpisode = playlistEpisode[index + 1]
    }
    self.episode = nextEpisode
  }
  
  private func handlePreviousTrack() {
    
    if playlistEpisode.count == 0 { return }
    
    let currentEpisodeIndex = playlistEpisode.firstIndex(where: { (ep) in
      return self.episode.title == ep.title && self.episode.author == ep.author
    })
    guard let index = currentEpisodeIndex else { return }
    
    let prevoiusEpisode: Episode
    
    if index == 0 {
      prevoiusEpisode = playlistEpisode[playlistEpisode.count - 1]
    } else {
      prevoiusEpisode = playlistEpisode[index - 1]
    }
    self.episode = prevoiusEpisode
  }
  
  private func  observeLocksreenDuration() {
    
    guard let duration = player.currentItem?.duration else { return }
    let durationInSeconds = CMTimeGetSeconds(duration)
    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
  }
  
  private func setupElapsedTime(playbackRate: Float) {
    let elapsedTime = CMTimeGetSeconds(player.currentTime())
    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate // to display the left timer in lockscreen correctly
  }
  
  private func setupInterruptionObserver() {
    NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification , object: nil)
  }
  
  // MARK: - Selectors
  
  @objc func handlePlayPause() {
    if player.timeControlStatus == .paused {
      player.play()
      playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
      miniPlayPauseButton.setImage(UIImage(named: "pause"), for: .normal)
      enlargeEpisodeImageView()
      setupElapsedTime(playbackRate: 1)
    } else {
      player.pause()
      playPauseButton.setImage(UIImage(named: "play"), for: .normal)
      miniPlayPauseButton.setImage(UIImage(named: "play"), for: .normal)
      shrinkEpisodeImageView()
      setupElapsedTime(playbackRate: 0)
    }
  }
  
  @objc func handleTapMaximaze() {
    UIApplication.MainTabBarController()?.maximazePlayerDetails(episode: nil)
  }
  
  @objc func handlePan(gesture: UIPanGestureRecognizer) {
    
    if gesture.state == .began {
      print("DEBUG: Began")
    } else if gesture.state == .changed {
      handlePanChanged(gesture: gesture)
    } else if gesture.state == .ended {
      handlePanEnded(gesture: gesture)
    }
  }
  
  @objc func handleDismissalPan(gesture: UIPanGestureRecognizer) {
    if gesture.state == .began {
      print("DEBUG: Began")
    } else if gesture.state == .changed {
      handleDismissalPanChanged(gesture: gesture)
    } else if gesture.state == .ended {
      handleDismissalPanEnded(gesture: gesture)
    }
  }
  
  @objc private func handleInterruption(notification: Notification) {
    print("DEBUG: Interruption observed")
    guard let userInfo = notification.userInfo else { return }
    guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
    if type == AVAudioSession.InterruptionType.began.rawValue {
      print("DEBUG: Interruption began")
      
      playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
      miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
    } else {
      print("DEBUG: Interruption ended")
      
      guard let option = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
      
      if option == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
        
        player.play()
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
      }
      
    }
  }
  
  
}
