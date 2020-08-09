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

        
        for _ in 0..<numberOfItemsInSection {
            var newRow: [GridCell] = []
            for _ in 0..<numberOfSections {
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
    
    func gameDifficultyToStringEnumMapping() -> String {
        switch difficulty {
        case .Beginner:
            return "Beginner"
        case .Intermediate:
            return "Intermediate"
        case .Advanced:
            return "Advanced"
        }
    }
    
    func isOutOfBounds(row: Int, section: Int) -> Bool {
        return row < 0 || section < 0 || row >= numberOfItemsInSection || section >= numberOfSections
    }
    
    func isAtSelectedIndexPath(indexPath: IndexPath, row: Int, section: Int) -> Bool {
        return (row == indexPath.row && section == indexPath.section)
    }
    
    func getValidIndexPathsSurroundingCell(_ indexPath: IndexPath) -> Array<IndexPath> {
        var validIndexPaths = Array<IndexPath>()
        for i in (indexPath.row - 1)...(indexPath.row + 1) {
            for j in (indexPath.section - 1)...(indexPath.section + 1) {
                if !isOutOfBounds(row: i, section: j) && !isAtSelectedIndexPath(indexPath: indexPath, row: i, section: j) {
                    validIndexPaths.append(IndexPath.init(row: i, section: j))
                }
            }
        }
        return validIndexPaths
    }
    
    mutating func randomlyDistributeMines(indexPathOfInitialCell: IndexPath) {
        var mineIndexPaths = Set<IndexPath>()
        while mineIndexPaths.count < numberOfMines {
            let randomRow = Int.random(in: 0...(numberOfItemsInSection - 1))
            let randomSection = Int.random(in: 0...(numberOfSections - 1))
            let randomIndexPath = IndexPath.init(row: randomRow, section: randomSection)
            if randomIndexPath != indexPathOfInitialCell {
                mineIndexPaths.insert(randomIndexPath)
            }
        }
        indexPathsOfMines = mineIndexPaths
    }
        
//    mutating func reconfigureGridCells() {
//        for item in 0..<numberOfItemsInSection {
//            var newRow: [GridCell] = []
//            for section in 0..<numberOfSections {
//                var cell = GridCell()
//                cell.hasMine = indexPathsOfMines.contains(IndexPath(row: item, section: section))
//                newRow.append(cell)
//            }
//            gridCells.append(newRow)
//        }
//    }
}
