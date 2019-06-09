//
//  ViewController.swift
//  Minesweeper
//
//  Created by Fiona Wilson on 25/02/2019.
//  Copyright © 2019 Fiona Wilson. All rights reserved.
//

import UIKit

enum NumberOfSections: Int {
    case Beginner = 8
    case Intermediate = 10
    case Advanced = 12
}

enum NumberOfItemsInSection: Int {
    case Beginner = 8
    case Intermediate = 9
    case Advanced = 10
}

enum NumberOfMines: Int {
    case Beginner = 15
    case Intermediate = 30
    case Advanced = 50
}

enum GameDifficulty: Int {
    case Beginner = 1
    case Intermediate = 2
    case Advanced = 3
}

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var headerView: HeaderView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var indexPathsOfMines = Set<IndexPath>()
    var adjacentIndexPathsWithZeroMinesInVicinity = Set<IndexPath>()
    var gameDifficulty: GameDifficulty?
    var numberOfItemsInSection = 0
    var numberOfSections = 0
    var numberOfMines = 0
    var remainingFlags = 0
    
    var timerStarted = false
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        self.resetGame()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpGame()
        self.setUpGestureRecognizers()
    }
    
    func getNumberOfMines(gameDifficulty: GameDifficulty) -> Int {
        switch gameDifficulty {
        case .Beginner:
            return NumberOfMines.Beginner.rawValue
        case .Intermediate:
            return NumberOfMines.Intermediate.rawValue
        case .Advanced:
            return NumberOfMines.Advanced.rawValue
        }
    }
    
    func getNumberOfItemsInSection(gameDifficulty: GameDifficulty) -> Int {
        switch gameDifficulty {
        case .Beginner:
            return NumberOfItemsInSection.Beginner.rawValue
        case .Intermediate:
            return NumberOfItemsInSection.Intermediate.rawValue
        case .Advanced:
            return NumberOfItemsInSection.Advanced.rawValue
        }
    }
    
    func getNumberOfSections(gameDifficulty: GameDifficulty) -> Int {
        switch gameDifficulty {
        case .Beginner:
            return NumberOfSections.Beginner.rawValue
        case .Intermediate:
            return NumberOfSections.Intermediate.rawValue
        case .Advanced:
            return NumberOfSections.Advanced.rawValue
        }
    }
    
    func setUpGame() {
        
        if let gameDifficulty = self.gameDifficulty {
            // set game properties according to chosen difficulty
            self.numberOfMines = self.getNumberOfMines(gameDifficulty: gameDifficulty)
            self.numberOfItemsInSection = self.getNumberOfItemsInSection(gameDifficulty: gameDifficulty)
            self.numberOfSections = self.getNumberOfSections(gameDifficulty: gameDifficulty)
            self.remainingFlags = self.numberOfMines
            self.headerView.updateFlagsLabel(numberOfFlags: self.remainingFlags)
            self.headerView.configureResetButtonForNewGame()
            self.indexPathsOfMines = Set<IndexPath>()
        }
    }
    
    func resetGame() {
        self.configureTimerForReset()
        self.setUpGame()
        self.collectionView.reloadData()
    }
    
    func setUpLongPressGestureRecognizer() {
        let longPressGestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        longPressGestureRecogniser.minimumPressDuration = 0.25
        self.collectionView.addGestureRecognizer(longPressGestureRecogniser)
    }
    
    func setUpTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.collectionView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setUpGestureRecognizers() {
        self.setUpTapGestureRecognizer()
        self.setUpLongPressGestureRecognizer()
    }
    
    func configureTimerForReset() {
        self.headerView.timer.invalidate()
        self.headerView.resetTimer()
        self.timerStarted = false
    }
    
    // MARK: UICollectionViewDelegate, UICollectionViewDataSource and UICollectionViewDelegateFlowLayout methods

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
    
    
    // MARK: Helper functions
    
    func collectionView(_ collectionView: UICollectionView, tappedForCellAt indexPath: IndexPath) {
        
        if (!timerStarted) {
            
            self.indexPathsOfMines = self.randomlyDistributeMines(indexPathOfInitialCell: indexPath)
            self.collectionView.reloadItems(at: Array(self.indexPathsOfMines))
            
            timerStarted = true
            self.headerView.timer = Timer.scheduledTimer(timeInterval: 1, target: self.headerView, selector: #selector(self.headerView.updateTimer), userInfo: nil, repeats: true)
        }
        
        let cell: CollectionViewCell = self.collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        
        if cell.hasFlag || cell.uncovered {
            return
        }
        
        if cell.hasMine {
            self.gameOver(clickedCell: cell)
            return
        }
        
        let minesInVicinity = numberOfMinesInVicinityOfCellAt(indexPath: indexPath)
        
        cell.configureForMinesInVicinity(numberOfMines: minesInVicinity)
        
        if self.isGameWon() {
            self.handleGameWon()
        }
        
        // Now check adjacent cells
        
//        var numberOfCellsWithZeroAdjacentMines = 0
//        
//        let validAdjacentIndexPaths = self.getValidAdjacentIndexPaths(indexPath: indexPath)
//        
//        for adjacentIndexPath in validAdjacentIndexPaths {
//            let adjacentCell: CollectionViewCell = self.collectionView.cellForItem(at: adjacentIndexPath) as! CollectionViewCell
//            let numberOfMinesInVicinity = numberOfMinesInVicinityOfCellAt(indexPath: adjacentIndexPath)
//            adjacentCell.configureForMinesInVicinity(numberOfMines: numberOfMinesInVicinity)
//            if numberOfMinesInVicinity == 0 {
//                numberOfCellsWithZeroAdjacentMines += 1
//            }
//        }
//        
//        if numberOfCellsWithZeroAdjacentMines == 0 {return}
        
    }
    
    func collectionView(_ collectionView: UICollectionView, longPressForCellAt indexPath: IndexPath) {
        
        let cell = self.collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        
        if cell.uncovered {
            return
        }
        
        if (self.remainingFlags > 0 && !cell.hasFlag) {
            cell.hasFlag = true
            self.remainingFlags -= 1
        }
        else if cell.hasFlag {
            cell.hasFlag = false
            self.remainingFlags += 1
        }
        
        cell.configureFlagContainingCell()
        
        self.headerView.updateFlagsLabel(numberOfFlags: self.remainingFlags)
    }
    
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            let locationOfGesture = gesture.location(in: self.collectionView)
            let indexPath = self.collectionView.indexPathForItem(at: locationOfGesture)
            if (indexPath != nil) {
                self.collectionView(self.collectionView, tappedForCellAt: indexPath!)
            }
        }
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            
            let locationOfGesture = gesture.location(in: self.collectionView)
            let indexPath = self.collectionView.indexPathForItem(at: locationOfGesture)
            if indexPath != nil {
                self.collectionView(self.collectionView, longPressForCellAt: indexPath!)
            }
        }
    }
    
    func randomlyDistributeMines(indexPathOfInitialCell: IndexPath) -> Set<IndexPath> {
        
        var mineIndexPaths = Set<IndexPath>()
        
        while mineIndexPaths.count < numberOfMines {
            let randomRow = Int.random(in: 0...(numberOfItemsInSection - 1))
            let randomSection = Int.random(in: 0...(numberOfSections - 1))
            let randomIndexPath = IndexPath.init(row: randomRow, section: randomSection)
            if !mineIndexPaths.contains(randomIndexPath) && (randomIndexPath != indexPathOfInitialCell) {
                mineIndexPaths.insert(randomIndexPath)
            }
        }
        
//        for i in 0...9 {
//            mineIndexPaths.insert(IndexPath.init(row: i, section: 0))
//        }
        
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
    
    func showAllUnflaggedMines() {
        for cell: CollectionViewCell in self.collectionView!.visibleCells as! Array<CollectionViewCell> {

            if cell.hasMine && !cell.hasFlag {
                cell.configureMineContainingCell()
            }
            else if !cell.hasMine && cell.hasFlag {
                cell.configureForMisplacedFlag()
            }
        }
    }
    
    func disableUserInteractionOnAllCells() {
        for cell: CollectionViewCell in (self.collectionView!.visibleCells as! Array<CollectionViewCell>) {
            cell.uncovered = true
        }
    }
    
    func gameOver(clickedCell: CollectionViewCell) {
        self.showAllUnflaggedMines()
        self.headerView.configureResetButtonForGameOver()
        clickedCell.configureForGameOver()
        self.disableUserInteractionOnAllCells()
        self.headerView.timer.invalidate()
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
    
    func isGameWon() -> Bool {
        var clickedCellCount = 0
        for cell: CollectionViewCell in (self.collectionView!.visibleCells as! Array<CollectionViewCell>) {
            if cell.hasFlag || cell.uncovered {
                clickedCellCount += 1
            }
        }
        
        let totalNumberOfCellsInCollectionView = self.numberOfSections * self.numberOfItemsInSection
        return clickedCellCount == totalNumberOfCellsInCollectionView - self.remainingFlags
    }
    
    func handleGameWon() {
        
        self.headerView.timer.invalidate()
        self.headerView.setNumberOfFlagsLabelForGameWon()
        self.headerView.configureResetButtonForGameWon()
        self.addFlagsToUncoveredCells()
        
        let winningTime = self.headerView.timeLabel.text
        self.displayGameWonAlert(winningTime: winningTime!)
    }
    
    func displayGameWonAlert(winningTime: String) {
        let alert = UIAlertController(title: "You won!", message: "Your time was \(winningTime) seconds", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "New Game", style: .default, handler: self.newGameHandler))
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func newGameHandler(alert: UIAlertAction!) {
        self.resetGame()
    }
    
    func addFlagsToUncoveredCells() {
        for cell: CollectionViewCell in (self.collectionView!.visibleCells as! Array<CollectionViewCell>) {
            if !cell.uncovered {
                cell.hasFlag = true
                cell.configureFlagContainingCell()
            }
        }
    }
//    func configureCellsWithZeroMinesInVicinity(indexPaths: Set<IndexPath>) {
//        for indexPath in indexPaths {
//            let cell: CollectionViewCell = self.collectionView.cellForItem(at: indexPath) as! CollectionViewCell
//            cell.configureForZeroMinesInVicinity()
//        }
//    }
//
//    func updateAdjacentIndexPathsWithZeroMinesInVicinity(indexPath: IndexPath) {
//
//        let validAdjacentIndexPaths = self.getValidAdjacentIndexPaths(indexPath: indexPath)
//
//        for indexPath in validAdjacentIndexPaths {
//            if self.numberOfMinesInVicinityOfCellAt(indexPath: indexPath) == 0 {
//                adjacentIndexPathsWithZeroMinesInVicinity.insert(indexPath)
//            }
//        }
//    }

}

