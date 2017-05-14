//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by Daeyun Ethan Kim on 05/01/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    
    // MARK: Outlets
    
    @IBOutlet weak var snailButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var fastRewindButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var fastForwardButton: UIButton!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var volumeUpButton: UIButton!
    @IBOutlet weak var volumeDownButton: UIButton!
    
    @IBOutlet weak var currentPlayTime: UILabel!
    @IBOutlet weak var playTimeLabel: UILabel!
    
    // MARK: Properties
    
    var recordedAudioURL: URL!
    var audioFile:AVAudioFile!
    var audioEngine:AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    
    var stopTimer: Timer!
    
    var currentTime: Double! = 0
    var audioDuration: Double!
    var tag: Int?
    
    
    enum ButtonType: Int {
        case slow = 0, fast, chipmunk, vader, echo, reverb
    }
    
    
    // MARK: Actions
    
    @IBAction func playSoundForButton(_ sender: UIButton) {
        let rounded = roundedToDouble(self.audioDuration)
        
        switch(ButtonType(rawValue: sender.tag)!) {
        case .slow:
            self.tag = 0
            playTimeLabel.text = String("    \(rounded*2)")
        case .fast:
            self.tag = 1
            playTimeLabel.text = String("    \(rounded/2)")
        case .chipmunk:
            self.tag = 2
        case .vader:
            self.tag = 3
        case .echo:
            self.tag = 4
        case .reverb:
            self.tag = 5
        }
        
        playController(self.tag!)
        configureUI(.playing)
    }
    
    @IBAction func pauseButtonPressed(_ sender: Any) {
        if audioPlayerNode.isPlaying {
            if let stopTimer = stopTimer {
                if let image = UIImage(named: "Play") {
                    pauseButton.setImage(image, for: UIControlState.normal)
                }
                stopTimer.invalidate()
                audioPlayerNode.pause()
            }
            
        } else {
            if let stopTimer = stopTimer {
                if let image = UIImage(named: "Pause-1") {
                    pauseButton.setImage(image, for: UIControlState.normal)
                }
                var delayInSeconds: Double
                if tag == 0 {
                    delayInSeconds = (audioDuration - currentTime) / 0.5
                } else if tag == 1{
                    delayInSeconds = audioDuration - currentTime / 1.5
                } else {
                    delayInSeconds = audioDuration - currentTime
                }
                self.setTimer(delayInSeconds)
                audioPlayerNode.play()
            }
        }
    }
    
    @IBAction func stopButtonPressed(_ sender: AnyObject) {
    
        stopAudio()
    }
    
//    @IBAction func fastRewindButtonPressed(_ sender: Any) {
//        stopTimer.invalidate()
//        audioPlayerNode.pause()
//        
//        let newsampleTime = AVAudioFramePosition(audioFile.processingFormat.sampleRate * currentTime)
//        let length = Float(audioDuration) - Float(currentTime) - 0.1
//        let framesToPlay = AVAudioFrameCount(Float(audioFile.processingFormat.sampleRate) * length)
//        
//        audioPlayerNode.stop()
//        
//        if framesToPlay > 100 {
//            audioPlayerNode.scheduleSegment(audioFile, startingFrame: newsampleTime, frameCount: framesToPlay, at: nil,completionHandler: nil)
//        }
//        
//        var delayInSeconds: Double
//        if tag == 0 {
//            delayInSeconds = (audioDuration - currentTime) / 0.5
//        } else if tag == 1{
//            delayInSeconds = audioDuration - currentTime / 1.5
//        } else {
//            delayInSeconds = audioDuration - currentTime
//        }
//        self.setTimer(delayInSeconds)
//        audioPlayerNode.play()
//    }
    
//    @IBAction func fastForwardButtonPressed(_ sender: Any) {
//        stopTimer.invalidate()
//        audioPlayerNode.pause()
//        
//        var delayInSeconds: Double
//        if tag == 0 {
//            delayInSeconds = (audioDuration - currentTime) / 0.5
//        } else if tag == 1{
//            delayInSeconds = audioDuration - currentTime / 1.5
//        } else {
//            delayInSeconds = audioDuration - currentTime
//        }
//        self.setTimer(delayInSeconds)
//        audioPlayerNode.play()
//    }
    
    @IBAction func replayButtonPressed(_ sender: Any) {
        stopAudio()
        currentTime = 0
        playController(self.tag!)
        configureUI(.playing)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAudio()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureUI(.notPlaying)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopAudio()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
