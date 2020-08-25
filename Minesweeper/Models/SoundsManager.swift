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
    
    private var soundsOn: Bool {
        if UserDefaults.standard.object(forKey: Constants.UserDefaults.soundsOn) == nil {
            // Used when app is first installed to set the appropriate key for sounds
            UserDefaults.standard.set(true, forKey: Constants.UserDefaults.soundsOn)
            return true
        }
        return UserDefaults.standard.bool(forKey: Constants.UserDefaults.soundsOn)
    }
    
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
