//
//  Enums.swift
//  Minesweeper
//
//  Created by Fiona on 09/08/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

enum NumberOfMines: Int {
    case Beginner = 11
    case Intermediate = 14
    case Advanced = 18
    
    static func numberOfMinesForDifficulty(difficulty: GameDifficulty) -> Int {
        switch difficulty {
        case .Beginner:
            return NumberOfMines.Beginner.rawValue
        case .Intermediate:
            return NumberOfMines.Intermediate.rawValue
        case .Advanced:
            return NumberOfMines.Advanced.rawValue
        }
    }
}

enum GameDifficulty: String, CaseIterable {
    case Beginner = "Beginner"
    case Intermediate = "Intermediate"
    case Advanced = "Advanced"
    
    static func selectedIndexForDifficulty(_ difficulty: String) -> Int {
        guard let index = allCases.map({$0.rawValue}).firstIndex(of: difficulty) else {
            fatalError("The selected difficulty doesn't appear in GameDifficulty enum.")
        }
        return index
    }
}
