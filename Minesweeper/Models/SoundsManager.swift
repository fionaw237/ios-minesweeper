//
//  SoundsManager.swift
//  Minesweeper
//
//  Created by Fiona on 25/08/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import Foundation
import AVFoundation

struct SoundsManager {
    
    private var audioPlayer: AVAudioPlayer?
    
    @DefaultSynced(key: "soundsOn", defaultValue: true)
    private var soundsOn: Bool
    
    var soundToggleImageName: String {
        if soundsOn {
            return Constants.Images.soundsOn
        } else {
            return Constants.Images.soundsOff
        }
    }
    
    func toggleSounds() {
        UserDefaults.standard.set(!soundsOn, forKey: Constants.UserDefaults.soundsOn)
    }
    
    mutating func playSound(_ filename: String) {
        if soundsOn {
            let soundFile = Bundle.main.path(forResource: filename, ofType: nil)!
            let url = URL(fileURLWithPath: soundFile)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                // This line will prevent music from another app stopping
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
                audioPlayer?.play()
            }
            catch {
                print("Error with sounds: \(error)")
            }
        }
    }
}
