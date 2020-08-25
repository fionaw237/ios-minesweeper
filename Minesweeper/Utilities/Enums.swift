//
//  Enums.swift
//  Minesweeper
//
//  Created by Fiona on 09/08/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

enum NumberOfSections: Int {
    case Beginner = 9
    case Intermediate = 10
    case Advanced = 11
    
    static func numberOfSectionsForDifficulty(difficulty: GameDifficulty) -> Int {
        switch difficulty {
        case .Beginner:
            return NumberOfSections.Beginner.rawValue
        case .Intermediate:
            return NumberOfSections.Intermediate.rawValue
        case .Advanced:
            return NumberOfSections.Advanced.rawValue
        }
    }
}

enum NumberOfMines: Int {
    case Beginner = 10
    case Intermediate = 14
    case Advanced = 20
    
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
