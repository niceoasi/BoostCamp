//
//  FileUtils.swift
//  PitchPerfect
//
//  Created by Daeyun Ethan Kim on 10/01/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import Foundation


// 사용자 데이터를 저장하는 파일 생성 클래스

class FileUtils {
    var fileName = ""
    var defaultDirectory: URL
    var pathUrl: URL
    var fileMgr: FileManager
    
    //    init(fileName: String, location: String) {
    //        self.fileName = fileName
    //        path = location + "/" + fileName
    //    }
    
    // 초기화 부분
    
    init(fileName: String) {
        self.fileName = fileName
        fileMgr = FileManager.default
        defaultDirectory = try! fileMgr.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        pathUrl = defaultDirectory.appendingPathComponent(fileName)
        
        print(pathUrl.path)
    }
    
    
    // 파일 생성
    
    func creatFile(outputData: String) {
        fileMgr.createFile(atPath: pathUrl.path, contents: outputData.data(using: String.Encoding.utf8), attributes: nil)
    }
    
    
    // 파일이 있는지 없는지 검사
    
    func fileExists() -> Bool {
        return fileMgr.fileExists(atPath: pathUrl.path)
    }
    
    
    // 파일에 데이터를 추가하는 부분
    // 여기서 데이터 쓰는 함수를 불러옴
    
    func appendFile(outputData: String) -> Bool {
        var retVal = false
        if(!fileExists()) {
            creatFile(outputData: outputData)
        } else {
            do {
                let file: FileHandle? = try FileHandle(forWritingTo: pathUrl)
                file?.seekToEndOfFile()
                file?.write(outputData.data(using: String.Encoding.utf8)!)
                file?.closeFile()
                retVal = true
            } catch let error as NSError {
                print("File Error in appending: \(error)")
            }
        }
        
        return retVal
    }
    
    
    // 파일을 읽어오는 부분
    
    func readFile() -> String {
        var retStr = ""
        
        let content = NSData(contentsOf: pathUrl)
        let dataString = String(data: content! as Data, encoding: String.Encoding.utf8)
        
        if let c = dataString {
            retStr = c
        }
        return retStr
    }
    
    
    // 파일에 데이터를 쓰는 부분
    
    func writeFile(data: String) -> Bool {
        var retVal = false
        
        do {
            try data.write(to: pathUrl, atomically: true, encoding: String.Encoding.utf8)
            retVal = true
        } catch let error as NSError{
            print("Error : \(error)")
        }
        
        return retVal
    }
    
    
    // 파일의 데이터를 지우는 부분
    
    func clearFile() {
        do {
            let file: FileHandle? = try FileHandle(forWritingTo: pathUrl)
            file?.truncateFile(atOffset: 0)
            file?.closeFile()
        } catch let error as NSError {
            print("File Error in clearFile : \(error)")
        }
    }
}
