//
//  GameLogic.swift
//  Minesweeper
//
//  Created by Fiona on 09/08/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//
import Foundation

struct GameLogic {
    var gridCells: [[GridCell]] = []
    var difficulty: GameDifficulty = .Beginner
    
    var numberOfSections = 0
    var numberOfItemsInSection = 0
    var numberOfMines = 0
    var remainingFlags = 0
    
    var timerStarted = false
    
    var indexPathsOfMines = Set<IndexPath>()
    var indexPathsOfFlags = Set<IndexPath>()
    var adjacentIndexPathsWithZeroMinesInVicinity = Set<IndexPath>()
    
    init(difficulty: GameDifficulty) {
        self.difficulty = difficulty
        
        numberOfSections = getNumberOfRows()
        numberOfItemsInSection = getNumberOfColumns()
        numberOfMines = getNumberOfMines()
        remainingFlags = numberOfMines

        
        for _ in 0..<numberOfSections {
            var newRow: [GridCell] = []
            for _ in 0..<numberOfItemsInSection {
                newRow.append(GridCell())
            }
            gridCells.append(newRow)
        }
    }
    
    init() {
        // blank
    }
    
        func getNumberOfRows() -> Int {
            return 8
    //        switch gameDifficulty {
    //        case .Beginner:
    //            return NumberOfItemsInSection.Beginner.rawValue
    //        case .Intermediate:
    //            return NumberOfItemsInSection.Intermediate.rawValue
    //        case .Advanced:
    //            return NumberOfItemsInSection.Advanced.rawValue
    //        }
        }
        
        func getNumberOfColumns() -> Int {
            return 9
    //        switch gameDifficulty {
    //        case .Beginner:
    //            return NumberOfSections.Beginner.rawValue
    //        case .Intermediate:
    //            return NumberOfSections.Intermediate.rawValue
    //        case .Advanced:
    //            return NumberOfSections.Advanced.rawValue
    //        }
        }
    
    func getNumberOfMines() -> Int {
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
