//
//  Constants.swift
//  Minesweeper
//
//  Created by Fiona on 09/08/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//
import UIKit

struct Constants {
    
    struct Colours {
        static let darkBlue = UIColor(red: 24.0 / 255.0, green: 49.0 / 255.0, blue: 237.0 / 255.0, alpha: 1.0)
        static let navBarTitle = UIColor.darkGray
    }
    
    struct Fonts {
        static let navBarTitle = UIFont(name: "Copperplate", size: 24.0) ?? UIColor.black
        static let difficultySelector = UIFont(name: "Copperplate", size: 16.0) ?? UIColor.black
    }
    
    struct HighScores {
        static let numberOfHighScoresToDisplay = 10
    }
    
    struct Images {
        static let mine = "mine-icon-black-50"
        static let flag = "icon-flag-48"
        static let happyFace = "icon-happy-48"
        static let sadFace = "icon-sad-48"
        static let coolFace = "icon-cool-48"
        static let soundsOn = "speaker.fill"
        static let soundsOff = "speaker.slash.fill"
    }
   
    struct Segues {
        static let newHighScore = "newHighScoreSegue"
        static let viewHighScores = "bestTimesSegue"
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
        static let titleLabelText = "Minesweeper!"
    }
}
