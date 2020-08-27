//
//  Constants.swift
//  Minesweeper
//
//  Created by Fiona on 09/08/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import UIKit

struct Constants {
    
    struct BestTimes {
        static let numberOfBestTimesToDisplay = 10
    }
    
    struct Images {
        static let mine = "mine-icon-black-50"
        static let flag = "icon-flag-48"
        static let happyFace = "icon-happy-48"
        static let sadFace = "icon-sad-48"
        static let coolFace = "icon-cool-48"
        static let soundsOn = "speaker.2.fill"
        static let soundsOff = "speaker.slash.fill"
    }
   
    struct Segues {
        static let newBestTime = "newBestTimeSegue"
        static let viewBestTimes = "bestTimesSegue"
        static let goToGameScreen = "goToGameScreenSegue"
    }

    struct Sounds {
        static let click = "click.wav"
        static let flag = "flag.wav"
        static let gameWon = "game_won.wav"
        static let gameOver = "game_over.mp3"
    }
    
    struct UserDefaults {
        static let soundsOn = "soundsOn"
    }
    
    struct WelcomeScreen {
        static let titleLabelText = "Minesweeper"
    }
}
