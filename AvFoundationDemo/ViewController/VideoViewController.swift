//
//  VideoViewController.swift
//  AvFoundationDemo
//
//  Created by Work on 2021-01-15.
//

import UIKit
import AVFoundation
import AVKit

class VideoViewController : UIViewController {
    
    var player : AVPlayer!
    var playerViewController : AVPlayerViewController!
    
    @IBOutlet weak var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            try loadRemoteVideo()
        }catch{
            print(error)
        }
    }
    
}

extension VideoViewController{
    
    func loadRemoteVideo() throws{
        let videoUrl = URL(string: "https://www.radiantmediaplayer.com/media/big-buck-bunny-360p.mp4")
        self.player = AVPlayer(url: videoUrl!)
        self.playerViewController = AVPlayerViewController()
        self.playerViewController.player = self.player
        self.playerViewController.view.frame = self.videoView.bounds
        //self.playerViewController.player?.pause()
        self.videoView.addSubview(self.playerViewController.view)
        self.playerViewController.player?.play()
        
    }
    
}
