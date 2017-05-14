//
//  RecordedAudioTableViewCell.swift
//  PitchPerfect
//
//  Created by Daeyun Ethan Kim on 13/01/2017.
//  Copyright © 2017 Daeyun Ethan Kim. All rights reserved.
//

import UIKit

// 녹음된 파일 셀 -> 사용자가 녹음된 파일을 선택 했을 때 델리게이트로 테이블 뷰로 전달

protocol RecordedAudioTableViewCellDelegete: class {
    func selectAudio(_ sender: String)
}

class RecordedAudioTableViewCell: UITableViewCell {

    @IBOutlet weak var recordedAudioButton: UIButton!
    
    var delegate: RecordedAudioTableViewCellDelegete? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // 녹음된 파일 버튼 클릭
    
    @IBAction func recordedAudioButtonSelected(_ sender: Any) {
        self.delegate?.selectAudio((recordedAudioButton.titleLabel?.text)!)
//        print("buttonSelected")
    }
    
}


