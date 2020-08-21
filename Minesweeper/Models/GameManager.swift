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
    
    var gridCells: [[GridCell]] = []
    var newCells: [GridCell] = []
    var difficulty = GameDifficulty.Beginner
    
    var numberOfSections = 0
    var numberOfItemsInSection = 0
    var numberOfMines = 0
    var remainingFlags = 0
    
    var timerStarted = false
    
    var indexPathsOfMines = Set<IndexPath>()
    private var indexPathsOfFlags = Set<IndexPath>()
    private var adjacentIndexPathsWithZeroMinesInVicinity = Set<IndexPath>()
    
    private var clickedCellCount: Int {
        return get1DGridCellsArray().filter {
            $0.hasFlag || $0.uncovered
        }.count
    }
    
    //MARK:- Methods for initialising number of rows, columns and mines
    
    private func getNumberOfRows() -> Int {
        return 8
    }
    
    private func getNumberOfColumns() -> Int {
        return 9
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
    
    private func isOutOfBounds(row: Int, section: Int) -> Bool {
        return !(0..<numberOfItemsInSection).contains(row) || !(0..<numberOfSections).contains(section)
    }
    
    private func isAtSelectedIndexPath(indexPath: IndexPath, row: Int, section: Int) -> Bool {
        return (row == indexPath.row) && (section == indexPath.section)
    }
    
    private func getValidIndexPathsSurroundingCell(_ indexPath: IndexPath) -> Array<IndexPath> {
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
        
        for cell in get1DGridCellsArray() {
            cell.hasMine = indexPathsOfMines.contains(cell.indexPath) 
        }
    }
    
    mutating func setCellPropertiesAfterLongPress(for indexPath: IndexPath) {
        let gridCell = gridCells[indexPath.row][indexPath.section]
        if (remainingFlags == 0 && !gridCell.hasFlag) {
            delegate?.presentNoFlagsWarning()
        } else if (remainingFlags > 0 && !gridCell.hasFlag) {
            gridCell.hasFlag = true
            indexPathsOfFlags.insert(indexPath)
            remainingFlags -= 1
        }
        else if gridCell.hasFlag {
            gridCell.hasFlag = false
            indexPathsOfFlags.remove(indexPath)
            remainingFlags += 1
        }
    }
    
    private func getTotalNumberOfCells() -> Int {
        return gridCells.flatMap{$0}.count
    }
    
    func numberOfMinesInVicinityOfCell(_ indexPath: IndexPath) -> Int {
        return getValidIndexPathsSurroundingCell(indexPath).filter {
            gridCells[$0.row][$0.section].hasMine
        }.count
    }
    
    func get1DGridCellsArray() -> [GridCell] {
        return gridCells.flatMap({$0})
    }
    
    func findCellsToReveal(_ indexPath: IndexPath) -> [IndexPath: Int] {
        var indexPathsChecked: Set<IndexPath> = [indexPath]
        var indexPathsWithZeroMines: Set<IndexPath> = [indexPath]
        
        var indexPathsToReveal = [IndexPath: Int]()
        
        while !indexPathsWithZeroMines.isEmpty {
            var indexPathsToCheck = Set<IndexPath>()
            indexPathsWithZeroMines.forEach {indexPathsToCheck.insert($0)}
            indexPathsWithZeroMines.removeAll()
            indexPathsToCheck.forEach { pathToCheck in
                let adjacentIndexPaths = getValidIndexPathsSurroundingCell(pathToCheck)
                // loop through adjacent index paths which have not already been checked
                adjacentIndexPaths.filter {!indexPathsChecked.contains($0)}
                    .forEach { adjacentIndexPath in
                        let minesInVicinity = numberOfMinesInVicinityOfCell(adjacentIndexPath)
                        indexPathsChecked.insert(adjacentIndexPath)
                        if minesInVicinity == 0 {
                            indexPathsWithZeroMines.insert(adjacentIndexPath)
                        }
                        
                        let gridCell = gridCells[adjacentIndexPath.row][adjacentIndexPath.section]
                        gridCell.uncovered = true
                        
                        if !gridCell.hasFlag {
                            indexPathsToReveal[adjacentIndexPath] = minesInVicinity
                        }
                }
            }
        }
        return indexPathsToReveal
    }
    
    func getUncoveredCells() -> [IndexPath] {
        var indexPathsOfUncoveredCells = [IndexPath]()
        for gridCell in get1DGridCellsArray() {
            if !gridCell.uncovered {
                gridCell.hasFlag = true
                indexPathsOfUncoveredCells.append(gridCell.indexPath)
            }
        }
        return indexPathsOfUncoveredCells
    }
    
    func isGameWon() -> Bool {
        return clickedCellCount == getTotalNumberOfCells() - remainingFlags
    }
    
    func getGridCellsWithUnflaggedMines() -> [GridCell] {
        return get1DGridCellsArray().filter { $0.hasMine && !$0.hasFlag }
    }
    
    func getGridCellsWithMisplacedFlags() -> [GridCell] {
        return get1DGridCellsArray().filter { !$0.hasMine && $0.hasFlag }
    }
    
    func arrayPositonFromIndexPath(_ indexpath: IndexPath) -> Int {
        return (indexpath.section * numberOfItemsInSection) + indexpath.row
    }
    
}




extension GameManager {
    
    // Additional initialiser to default one that comes with structs
    init(difficulty: GameDifficulty) {
        self.difficulty = difficulty
        
        numberOfSections = getNumberOfRows()
        numberOfItemsInSection = getNumberOfColumns()
        numberOfMines = getNumberOfMines()
        
        remainingFlags = numberOfMines

        
        for row in 0..<numberOfItemsInSection {
            var newRow: [GridCell] = []
            for section in 0..<numberOfSections {
                newRow.append(GridCell(indexPath: IndexPath(row: row, section: section)))
            }
            gridCells.append(newRow)
        }
        
        for section in 0..<numberOfSections {
            for item in 0..<numberOfItemsInSection {
                newCells.append(GridCell(indexPath: IndexPath(row: item, section: section)))
            }
        }      
        
    }
}
