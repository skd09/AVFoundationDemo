//
//  AudioViewController.swift
//  AvFoundationDemo
//
//  Created by Work on 2021-01-15.
//

import UIKit
import AVFoundation

class AudioViewController : UIViewController {
    
    private var audioPlayer : AVAudioPlayer!
    @IBOutlet weak var btnPlay: UIButton!
    private var audioMode : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            try loadSoundTrack()
        }catch{
            print(error)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        audioPlayer.stop()
        btnPlay.setImage(UIImage(named: "Play"), for: .normal)
    }
}

extension AudioViewController{
    
    @IBAction func onPlayClicked(_ sender: Any) {
        self.audioMode.toggle()
        if(self.audioMode){
            audioPlayer.play()
            btnPlay.setImage(UIImage(named: "Pause"), for: .normal)
        }else{
            audioPlayer.pause()
            btnPlay.setImage(UIImage(named: "Play"), for: .normal)
        }
    }
    
    
    func loadSoundTrack() throws{
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)
        let path = Bundle.main.path(forResource: "Summer Days", ofType: "mp3")
        audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path!))
        audioPlayer.prepareToPlay()
    }
    
    
}
