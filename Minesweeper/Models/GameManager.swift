//
//  GameLogic.swift
//  Minesweeper
//
//  Created by Fiona on 09/08/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//
import Foundation

protocol GameAlertDelegate {
    func presentNoFlagsWarning()
}

struct GameManager {
    var delegate: GameAlertDelegate?
    
    var gridCells: [GridCell] = []
    var difficulty = GameDifficulty.Beginner
    
    var numberOfSections = 8
    var numberOfItemsInSection = 9
    var numberOfMines = 0
    var remainingFlags = 0
    
    private var indexPathsOfMines = Set<IndexPath>()
    private var indexPathsOfFlags = Set<IndexPath>()
    private var adjacentIndexPathsWithZeroMinesInVicinity = Set<IndexPath>()
    
    
    //MARK:- Computed properties for grid cells
        
    var gridCellsWithUnflaggedMine: [GridCell] {
        return gridCells.filter { $0.hasUnflaggedMine }
    }
    
    var gridCellsWithMisplacedFlag: [GridCell] {
        return gridCells.filter { $0.hasMisplacedFlag }
    }
    
    var uncoveredCells: [GridCell] {
        return gridCells.filter { !$0.uncovered }
    }
    
    private var clickedCellCount: Int {
        return gridCells.filter {
            $0.hasFlag || $0.uncovered
        }.count
    }
    
    private func getNumberOfMines() -> Int {
        switch difficulty {
        case .Beginner:
            return NumberOfMines.Beginner.rawValue
        case .Intermediate:
            return NumberOfMines.Intermediate.rawValue
        case .Advanced:
            return NumberOfMines.Advanced.rawValue
        }
    }
    
    mutating func addFlag(to gridCell: GridCell) {
        gridCell.hasFlag = true
        indexPathsOfFlags.insert(gridCell.indexPath)
        remainingFlags -= 1
    }
    
    mutating func removeFlag(from gridCell: GridCell) {
        gridCell.hasFlag = false
        indexPathsOfFlags.remove(gridCell.indexPath)
        remainingFlags += 1
    }
    
    private func isOutOfBounds(row: Int, section: Int) -> Bool {
        return !(0..<numberOfItemsInSection).contains(row) || !(0..<numberOfSections).contains(section)
    }
    
    private func isAtSelectedIndexPath(indexPath: IndexPath, row: Int, section: Int) -> Bool {
        return (row == indexPath.row) && (section == indexPath.section)
    }
    
    private func isValidIndexPath(_ indexPath: IndexPath, row: Int, section: Int) -> Bool {
        return !isOutOfBounds(row: row, section: section) &&
            !isAtSelectedIndexPath(indexPath: indexPath, row: row, section: section)
    }
    
    private func surroundingRows(for indexPath: IndexPath) -> ClosedRange<Int> {
        return (indexPath.row - 1)...(indexPath.row + 1)
    }
    
    private func surroundingSections(for indexPath: IndexPath) -> ClosedRange<Int> {
        return (indexPath.section - 1)...(indexPath.section + 1)
    }
    
    private func validIndexPathsSurroundingCell(_ indexPath: IndexPath) -> Array<IndexPath> {
        
        var validIndexPaths = Array<IndexPath>()
        
        for row in surroundingRows(for: indexPath) {
            for section in surroundingSections(for: indexPath)
                where isValidIndexPath(indexPath, row: row, section: section) {
                validIndexPaths.append(IndexPath.init(row: row, section: section))
            }
        }
        
        return validIndexPaths
    }
    
    mutating func randomlyDistributeMines(indexPathOfInitialCell: IndexPath) {
        
        while indexPathsOfMines.count < numberOfMines {
            let randomRow = Int.random(in: 0...(numberOfItemsInSection - 1))
            let randomSection = Int.random(in: 0...(numberOfSections - 1))
            let randomIndexPath = IndexPath.init(row: randomRow, section: randomSection)
            
            if randomIndexPath != indexPathOfInitialCell {
                indexPathsOfMines.insert(randomIndexPath)
            }
        }
        
        for cell in gridCells {
            cell.hasMine = indexPathsOfMines.contains(cell.indexPath)
        }
    }
    
    mutating func setCellPropertiesAfterLongPress(for indexPath: IndexPath) {
        
        let gridCell = gridCellForIndexPath(indexPath)
        
        if (remainingFlags == 0 && !gridCell.hasFlag) {
            delegate?.presentNoFlagsWarning()
        } else if (remainingFlags > 0 && !gridCell.hasFlag) {
            addFlag(to: gridCell)
        }
        else if gridCell.hasFlag {
            removeFlag(from: gridCell)
        }
    }
    
    func disableUserInteractionOnAllCells() {
        gridCells.forEach { $0.uncovered = true }
    }
    
    func numberOfMinesInVicinityOfCell(_ indexPath: IndexPath) -> Int {
        return validIndexPathsSurroundingCell(indexPath).filter {
            gridCellForIndexPath($0).hasMine
        }.count
    }
    
    func findCellsToReveal(_ indexPath: IndexPath) -> [IndexPath: Int] {
        
        var indexPathsChecked: Set<IndexPath> = [indexPath]
        var indexPathsWithZeroMines: Set<IndexPath> = [indexPath]
        var indexPathsToReveal = [IndexPath: Int]()
        
        while !indexPathsWithZeroMines.isEmpty {
            let indexPathsToCheck = indexPathsWithZeroMines.map { $0 }
            indexPathsWithZeroMines.removeAll()
            
            for pathToCheck in indexPathsToCheck {
                // loop through adjacent index paths which have not already been checked
                for path in validIndexPathsSurroundingCell(pathToCheck) where !indexPathsChecked.contains(path) {
                    indexPathsChecked.insert(path)

                    let minesInVicinity = numberOfMinesInVicinityOfCell(path)
                    if minesInVicinity == 0 {
                        indexPathsWithZeroMines.insert(path)
                    }
                    let gridCell = gridCellForIndexPath(path)
                    gridCell.uncovered = true
                    
                    if !gridCell.hasFlag {
                        indexPathsToReveal[path] = minesInVicinity
                    }
                }
            }
        }
        return indexPathsToReveal
    }
    
    func isGameWon() -> Bool {
        return clickedCellCount == gridCells.count - remainingFlags
    }
    
    func arrayPositionForIndexPath(_ indexpath: IndexPath) -> Int {
        return (indexpath.section * numberOfItemsInSection) + indexpath.row
    }
    
    func gridCellForIndexPath(_ indexPath: IndexPath) -> GridCell {
        return gridCells[arrayPositionForIndexPath(indexPath)]
    }
    
}

extension GameManager {
    // Additional initialiser to default one that comes with structs
    init(difficulty: GameDifficulty) {
        self.difficulty = difficulty

        numberOfMines = getNumberOfMines()
        remainingFlags = numberOfMines
        
        for section in 0..<numberOfSections {
            for item in 0..<numberOfItemsInSection {
                gridCells.append(GridCell(indexPath: IndexPath(row: item, section: section)))
            }
        }
    }
}
