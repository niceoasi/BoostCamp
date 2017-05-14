//
//  PlaySoundsViewController+Audio.swift
//  PitchPerfect
//
//  Created by Daeyun Ethan Kim on 08/01/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - PlaySoundsViewController: AVAudioPlayerDelegate

extension PlaySoundsViewController: AVAudioPlayerDelegate {
    
    // MARK: Alerts
    
    struct Alerts {
        static let DismissAlert = "Dismiss"
        static let RecordingDisabledTitle = "Recording Disabled"
        static let RecordingDisabledMessage = "You've disabled this app from recording your microphone. Check Settings."
        static let RecordingFailedTitle = "Recording Failed"
        static let RecordingFailedMessage = "Something went wrong with your recording."
        static let AudioRecorderError = "Audio Recorder Error"
        static let AudioSessionError = "Audio Session Error"
        static let AudioRecordingError = "Audio Recording Error"
        static let AudioFileError = "Audio File Error"
        static let AudioEngineError = "Audio Engine Error"
    }
    
    // MARK: PlayingState (raw values correspond to sender tags)
    
    enum PlayingState { case playing, notPlaying }
    
    // MARK: Audio Functions
    
    func roundedToDouble(_ inputNumber: Double) -> Double {
        let numberOfPlaces = 2.0
        let multiplier = pow(10.0, numberOfPlaces)
        
        let num: Double = inputNumber * multiplier
        let roundedNumber = round(num)
        
        let rounded = roundedNumber / multiplier
        
        return rounded
    }
    
    func playController(_ tag: Int) {
        
        switch(tag) {
        case 0:
            playSound(rate: 0.5)
        case 1:
            playSound(rate: 1.5)
        case 2:
            playSound(pitch: 1000)
        case 3:
            playSound(pitch: -1000)
        case 4:
            playSound(echo: true)
        case 5:
            playSound(reverb: true)
        default:
            break
        }
    }
    
    func setupAudio() {
        // initialize (recording) audio file
        do {
            audioFile = try AVAudioFile(forReading: recordedAudioURL as URL)
            
            self.audioDuration = Double(self.audioFile.length) / Double(self.audioFile.processingFormat.sampleRate)
            
            let rounded = roundedToDouble(self.audioDuration)
            playTimeLabel.text = String("    \(rounded)")
            progressView.setProgress(Float(0), animated: false)
            
        } catch {
            showAlert(Alerts.AudioFileError, message: String(describing: error))
        }
        
        
    }
    
    // 주요 메소드
    func playSound(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) {
        
        // initialize audio engine components
        audioEngine = AVAudioEngine()
        
        // node for playing audio
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        // node for adjusting rate/pitch
        let changeRatePitchNode = AVAudioUnitTimePitch()
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        
        if let rate = rate {
            changeRatePitchNode.rate = rate
        } else {
            let rounded = roundedToDouble(self.audioDuration)
            playTimeLabel.text = String("    \(rounded)")
        }
        
        audioEngine.attach(changeRatePitchNode)
        
        // node for echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        audioEngine.attach(echoNode)
        
        // node for reverb
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        audioEngine.attach(reverbNode)
        
        // connect nodes
        if echo == true && reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
        } else if echo == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
        } else if reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
        } else {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
        }
        
        // schedule to play and start the engine!
        audioPlayerNode.stop()
        
        self.audioPlayerNode.scheduleFile(self.audioFile, at: nil) {
            
            var delayInSeconds: Double = 0
            
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
                
                if let rate = rate {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
                } else {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }
            // schedule a stop timer for when audio finishes playing
            self.setTimer(delayInSeconds)
        }
        
        
        do {
            try self.audioEngine.start()
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updatePlayTime), userInfo: nil, repeats: true)
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateAudioProgressView), userInfo: nil, repeats: true)
            self.progressView.setProgress(Float(self.currentTime/self.audioDuration), animated: false)
            
        } catch {
            self.showAlert(Alerts.AudioEngineError, message: String(describing: error))
            return
        }
        
        // play the recording!
        
        self.audioPlayerNode.play()
    }
    
    func setTimer(_ delayInSeconds: Double) {
        self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(PlaySoundsViewController.stopAudio), userInfo: nil, repeats: false)
        RunLoop.main.add(self.stopTimer!, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    func stopAudio() {
        
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        if let stopTimer = stopTimer {
            stopTimer.invalidate()
        }
        
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
        
        if let image = UIImage(named: "Pause-1") {
            pauseButton.setImage(image, for: UIControlState.normal)
        }
        
        configureUI(.notPlaying)
        
        progressView.setProgress(Float(0), animated: false)
        currentTime = 0
        currentPlayTime.text = String("  \(0)")
    }
    
    
    // MARK: Connect List of Audio Nodes
    
    func connectAudioNodes(_ nodes: AVAudioNode...) {
        for x in 0..<nodes.count-1 {
            audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }
    
    // MARK: UI Functions
    
    func configureUI(_ playState: PlayingState) {
        // to reset the buttons to the proper states when playing or not playing music
        
        switch(playState) {
        case .playing:
            setPlayButtonsEnabled(false)
            setControllButtonsEnabled(true)
        case .notPlaying:
            setPlayButtonsEnabled(true)
            setControllButtonsEnabled(false)
        }
    }
    
    func setPlayButtonsEnabled(_ enabled: Bool) {
        snailButton.isEnabled = enabled
        chipmunkButton.isEnabled = enabled
        rabbitButton.isEnabled = enabled
        vaderButton.isEnabled = enabled
        echoButton.isEnabled = enabled
        reverbButton.isEnabled = enabled
        
    }
    
    func setControllButtonsEnabled(_ enabled: Bool) {
        stopButton.isEnabled = enabled
        pauseButton.isEnabled = enabled
        replayButton.isEnabled = enabled
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // duration, playtime 설정
    func updatePlayTime() {
        if audioPlayerNode.isPlaying {
            if let nodeTime: AVAudioTime = self.audioPlayerNode.lastRenderTime, let playerTime: AVAudioTime = self.audioPlayerNode.playerTime(forNodeTime: nodeTime) {
                self.currentTime = Double(playerTime.sampleTime) / Double(playerTime.sampleRate)
                var rounded: Double
                
                if self.tag == 0 {
                    rounded = roundedToDouble(currentTime) * 2
                } else if self.tag == 1 {
                    rounded = roundedToDouble(currentTime) / 2
                } else {
                    rounded = roundedToDouble(currentTime)
                }
                self.currentPlayTime.text = String("  \(rounded)")
            }
        }
    }
    
    func updateAudioProgressView() {
        if audioPlayerNode.isPlaying {
            // Update progress
            progressView.setProgress(Float(currentTime/audioDuration), animated: true)
        }
    }
}



