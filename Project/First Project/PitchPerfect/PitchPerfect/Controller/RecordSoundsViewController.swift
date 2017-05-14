//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Daeyun Ethan Kim on 02/01/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    
    // MARK: Outlets
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var recordedSoundsList: UIButton!
    
    
    // MARK: Properties
    
    var audioRecorder: AVAudioRecorder!
    let logFile = FileUtils(fileName: "logfile.csv")
    var recordedName: String!
    
    // MARK: Actions
    
    @IBAction func recordAudio(_ sender: Any) {
        recordingLabel.text = "Recording in Progress"
        stopRecordingButton.isEnabled = true
        recordingButton.isEnabled = false
        
        
        let now = NSDate()
        let customFormatter = DateFormatter()
        customFormatter.dateFormat = "yyyy_MM_dd_hh_mm_ss"
        let dateStr = customFormatter.string(from: now as Date)
        
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "\(dateStr).wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
        recordedName = recordingName
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        recordingLabel.text = "Tap to Record"
        stopRecordingButton.isEnabled = false
        recordingButton.isEnabled = true
        
        
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
        let customEntry = "\(recordedName!)\n"
        
        let retVal = logFile.appendFile(outputData: customEntry)
        
        print(retVal ? "File Saved" : "File Error")
        
        
        audioRecorder.stop()
    }
    
    
    // MARK: Methods
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("Recording wasn't Successful")
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        stopRecordingButton.isEnabled = false
    }
    
    // log파일 체크
    override func viewWillAppear(_ animated: Bool) {
        
        if !logFile.fileExists() {
            recordedSoundsList.isEnabled = false
        } else {
            let rawLogData = logFile.readFile()
            var logEntries: Array<String> = rawLogData.components(separatedBy: "\n")
            logEntries.popLast()
            
            if logEntries.count == 0 {
                recordedSoundsList.isEnabled = false
            } else {
                recordedSoundsList.isEnabled = true
            }
        }
    }
}

