//
//  ViewController.swift
//  Minesweeper
//
//  Created by Fiona Wilson on 25/02/2019.
//  Copyright © 2019 Fiona Wilson. All rights reserved.
//

import UIKit

enum NumberOfSections: Int {
    case beginner = 8
    case intermediate = 10
    case advanced = 12
}

enum NumberOfItemsInSection: Int {
    case beginner = 8
    case intermediate = 12
    case advanced = 14
}

enum NumberOfMines: Int {
    case beginner = 10
    case intermediate = 30
    case advanced = 40
}

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var indexPathsOfMines = Set<IndexPath>()
    
    let numberOfItemsInSection = NumberOfSections.intermediate.rawValue
    let numberOfSections = NumberOfItemsInSection.intermediate.rawValue
    let numberOfMines = NumberOfMines.intermediate.rawValue
    var remainingFlags = 10
    
    var timerStarted = false
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        self.resetGame()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.remainingFlags = self.numberOfMines
        self.indexPathsOfMines = self.getRandomIndexPathsOfMines()
    }
    
    func resetGame() {
        self.indexPathsOfMines = self.getRandomIndexPathsOfMines()
        self.collectionView.reloadData()
    }
    
    func updateTimer() {
        print("update")
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsInSection
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier:"CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        cell.hasMine = (self.indexPathsOfMines.contains(indexPath))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width / CGFloat(numberOfItemsInSection)) - 2
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (!timerStarted) {
            timerStarted = true
//            Timer.scheduledTimer(timeInterval: (1.0/30.0), target: self, selector: Selector(), userInfo: nil, repeats: true)
        }
        
        let cell: CollectionViewCell = self.collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        
        if cell.hasMine {
            self.gameOver(clickedCell: cell)
            return
        }
        
        let minesInVicinity = numberOfMinesInVicinityOfCellAt(indexPath: indexPath)
        cell.configureNumberOfMinesLabel(numberOfMines: minesInVicinity)
    }
    
    func getRandomIndexPathsOfMines() -> Set<IndexPath> {
        
        var mineIndexPaths = Set<IndexPath>()
        
        while mineIndexPaths.count < numberOfMines {
            let randomRow = Int.random(in: 0...(numberOfItemsInSection - 1))
            let randomSection = Int.random(in: 0...(numberOfSections - 1))
            let randomIndexPath = IndexPath.init(row: randomRow, section: randomSection)
            if !mineIndexPaths.contains(randomIndexPath) {
                mineIndexPaths.insert(randomIndexPath)
            }
        }
        
        return mineIndexPaths
    }
    
    func numberOfMinesInVicinityOfCellAt(indexPath: IndexPath) -> Int {
        
        var mineCount = 0
        let validAdjacentIndexPaths = getValidAdjacentIndexPaths(indexPath: indexPath)
        
        for indexPath in validAdjacentIndexPaths {
            
            let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
            
            if cell.hasMine {
                mineCount += 1
            }
        }
        return mineCount
    }
    
    func showAllMines() {
        for cell: CollectionViewCell in self.collectionView!.visibleCells as! Array<CollectionViewCell> {
            if cell.hasMine {
                cell.configureMineContainingCell()
            }
        }
    }
    
    func disableUserInteractionOnAllCells() {
        for cell: CollectionViewCell in self.collectionView!.visibleCells as! Array<CollectionViewCell> {
            cell.isUserInteractionEnabled = false
        }
    }
    
    func gameOver(clickedCell: CollectionViewCell) {
        self.showAllMines()
        self.headerView.configureResetButtonForGameOver()
        clickedCell.configureForGameOver()
        self.disableUserInteractionOnAllCells()
    }
    
    func isOutOfBounds(row: Int, section: Int) -> Bool {
        return row < 0 || section < 0 || row >= numberOfItemsInSection || section >= numberOfSections
    }
    
    func isAtSelectedIndexPath(indexPath: IndexPath, row: Int, section: Int) -> Bool {
        return (row == indexPath.row && section == indexPath.section)
    }
    
    func getValidAdjacentIndexPaths(indexPath: IndexPath) -> Array<IndexPath> {
        
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
}

