//
//  RecordedSoundsListTableViewController.swift
//  PitchPerfect
//
//  Created by Daeyun Ethan Kim on 10/01/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit

// 녹음된 오디오 파일을 나타내주는 테이블 뷰

class RecordedSoundsListTableViewController: UITableViewController, RecordedAudioTableViewCellDelegete {
    
    var cellCount: Int!
    var logData: Array<String>!
    
    // 녹음된 파일이 있는지 체크
    
    func checkFile() {
        let logFile = FileUtils(fileName: "logfile.csv")
        
        if(logFile.fileExists()) {
            let rawLogData = logFile.readFile()
            let logEntries: Array<String> = rawLogData.components(separatedBy: "\n")
            logData = logEntries
            logData.popLast()
            cellCount = logData.count
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        checkFile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
        checkFile()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return cellCount!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "recordedAudioCell", for: indexPath) as! RecordedAudioTableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "recordedAudioCell") as! RecordedAudioTableViewCell
        }
        
        cell.recordedAudioButton.setTitle(logData[indexPath.row], for: UIControlState.normal)
        
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // 밀어서 데이터 삭제
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let logFile = FileUtils(fileName: "logfile.csv")
            
            let rawLogData = logFile.readFile()
            var logEntries: Array<String> = rawLogData.components(separatedBy: "\n")
            logEntries.remove(at: indexPath.row)
            
//            let urlFile = FileUtils(fileName: "logfile.csv")
//            var pathUrl = urlFile.defaultDirectory.appendingPathComponent(logEntries[indexPath.row])
//            print(String(pathUrl.path))
//            let fileManager = FileManager.default
//            
//            do {
//                try fileManager.removeItem(atPath: String(pathUrl.path))
//            }
//            catch let error as NSError {
//                print("Ooops! Something went wrong: \(error)")
//            }
            print(logEntries[indexPath.row])
            
            logFile.clearFile()
            
            for record: String in logEntries {
                if record != "" {
                    logFile.appendFile(outputData: "\(record)\n")
                }
            }
            cellCount = logEntries.count - 1
            

            
            self.tableView.reloadData()
        }
    }
    
    // 델리게이션
    
    func selectAudio(_ sender: String) {
        let urlFile = FileUtils(fileName: "logfile.csv")
        var pathUrl = urlFile.defaultDirectory.appendingPathComponent(sender)
        
        print("pathUrl.path \(pathUrl.path)")
        
        performSegue(withIdentifier: "selectRecord", sender: pathUrl)
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectRecord" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
    
}
