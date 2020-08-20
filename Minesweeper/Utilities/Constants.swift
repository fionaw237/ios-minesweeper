//
//  Constants.swift
//  Minesweeper
//
//  Created by Fiona on 09/08/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

struct Constants {
    
    struct Images {
        static let mine = "mine-icon-black-50"
        static let flag = "icon-flag-48"
        static let happyFace = "icon-happy-48"
        static let sadFace = "icon-sad-48"
        static let coolFace = "icon-cool-48"
    }

    struct Sounds {
        static let click = "click.wav"
        static let flag = "flag.wav"
        static let gameWon = "game_won.wav"
        static let gameOver = "game_over.mp3"
    }
    
    struct Segues {
        static let newHighScore = "newHighScoreSegue"
        static let viewHighScores = "bestTimesSegue"
        static let goToGameScreen = "goToGameScreenSegue"
    }
    
    struct HighScores {
        static let numberOfHighScoresToDisplay = 10
    }
}
