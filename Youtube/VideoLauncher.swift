//
//  VIdeoLauncher.swift
//  Youtube
//
//  Created by LeeChan on 10/18/16.
//  Copyright © 2016 MarkiiimarK. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayerView: UIView {
    
    var player: AVPlayer?
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        aiv.startAnimating()
        aiv.translatesAutoresizingMaskIntoConstraints = false
        return aiv
    }()
    
    lazy var pausePlayButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "pause"), for: .normal)
        btn.tintColor = .white
        btn.isHidden = true
        btn.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    var isPlaying = false
    
    let controlsContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0, alpha: 1)
        return v
    }()
    
    let videoLengthLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "00:00"
        lbl.textColor = .white
        lbl.font = .boldSystemFont(ofSize: 14)
        lbl.textAlignment = .right
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    lazy var videoSlider: UISlider = {
        let sldr = UISlider()
        sldr.minimumTrackTintColor = .red
        sldr.maximumTrackTintColor = .white
        sldr.setThumbImage(UIImage(named: "thumb"), for: .normal)
        sldr.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        sldr.translatesAutoresizingMaskIntoConstraints = false
        return sldr
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupPlayerView()
        
        controlsContainerView.frame = frame
        addSubview(controlsContainerView)
        
        controlsContainerView.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        controlsContainerView.addSubview(pausePlayButton)
        pausePlayButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        pausePlayButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        pausePlayButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        pausePlayButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        controlsContainerView.addSubview(videoLengthLabel)
        videoLengthLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        videoLengthLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        videoLengthLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        videoLengthLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        controlsContainerView.addSubview(videoSlider)
        videoSlider.rightAnchor.constraint(equalTo: videoLengthLabel.leftAnchor).isActive = true
        videoSlider.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        videoSlider.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        videoSlider.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        backgroundColor = .black
    }
    
    fileprivate func setupPlayerView() {
        // warning: use your own video url here, the bandwidth fo google firebase storage will run out
        let urlString = "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
        if let url = URL(string: urlString) {
            
            player = AVPlayer(url: url)
            let playerLayer = AVPlayerLayer(player: player)
            self.layer.addSublayer(playerLayer)
            playerLayer.frame = self.frame
            player?.play()
            player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        // this is when the player is ready and rendering frames
        if keyPath == "currentItem.loadedTimeRanges" {
            activityIndicatorView.stopAnimating()
            controlsContainerView.backgroundColor = .clear
            pausePlayButton.isHidden = false
            isPlaying = true
            
            if let duration = player?.currentItem?.duration {
                let seconds = CMTimeGetSeconds(duration)
                let secondsText = String(format: "%02d", Int(seconds) % 60)
                let minutesText = String(format: "%02d", Int(seconds) / 60)
                videoLengthLabel.text = "\(minutesText):\(secondsText)"
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objc fileprivate extension VideoPlayerView {
    func handlePause() {
        if isPlaying {
            #if DEBUG
            print("DEBUG: - VideoLauncher:handlePause\npausing player...\n")
            #endif
            player?.pause()
            pausePlayButton.setImage(UIImage(named: "play"), for: .normal)
        } else {
            player?.play()
            pausePlayButton.setImage(UIImage(named: "pause"), for: .normal)
        }
        isPlaying = !isPlaying
    }
    
    func handleSliderChange() {
        #if DEBUG
        print("DEBUG: VideoLauncher:handleSliderChange\nvideoSlider's value is changed to \(videoSlider.value)")
        #endif
        if let duration = player?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = Float64(videoSlider.value) * totalSeconds
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            
            player?.seek(to: seekTime, completionHandler: { (completedSeek) in
                // perhaps do something later here
            })
        }
        
    }
}


class VideoLauncher: NSObject {
    
    func showVideoPlayer() {
        #if DEBUG
            print("DEBUG: VideoLauncher:showVideoPlayer\nShowing video player animation...\n")
        #endif
        
        if let keyWindow = UIApplication.shared.keyWindow {
            let view = UIView(frame: keyWindow.frame)
            view.backgroundColor = .white
            
            view.frame = CGRect(x: keyWindow.frame.width - 10, y: keyWindow.frame.height - 10, width: 10, height: 10)
            
            // 16 * 9 is the aspect ratio of all HD videos
            let vpHeight = keyWindow.frame.width * 9 / 16
            let vpFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: vpHeight)
            let vpView = VideoPlayerView(frame: vpFrame)
            view.addSubview(vpView)
            
            keyWindow.addSubview(view)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                view.frame = keyWindow.frame
                
                }, completion: { (completedAnimation) in
                    // do something later
                    UIApplication.shared.setStatusBarHidden(true, with: .fade)
            })
        }
        
        
    }
}
