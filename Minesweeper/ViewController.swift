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
    case Advanced = 16
}

enum NumberOfItemsInSection: Int {
    case Beginner = 8
    case Intermediate = 9
    case Advanced = 10
}

enum NumberOfMines: Int {
    case Beginner = 15
    case Intermediate = 20
    case Advanced = 14
}

enum GameDifficulty: Int {
    case Beginner = 1
    case Intermediate = 2
    case Advanced = 3
}

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CellSelectionProtocol {
    
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
    
    @IBAction func resetButtonPressed(_ sender: Any) {resetGame()}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpGame()
        setUpGestureRecognizers()
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
        if let gameDifficulty = gameDifficulty {
            numberOfMines = getNumberOfMines(gameDifficulty: gameDifficulty)
            numberOfItemsInSection = getNumberOfItemsInSection(gameDifficulty: gameDifficulty)
            numberOfSections = getNumberOfSections(gameDifficulty: gameDifficulty)
            remainingFlags = numberOfMines
            headerView.updateFlagsLabel(numberOfFlags: remainingFlags)
            headerView.configureResetButtonForNewGame()
            indexPathsOfMines = Set<IndexPath>()
        }
    }
    
    func resetGame() {
        configureTimerForReset()
        setUpGame()
        collectionView.reloadData()
    }
    
    func setUpLongPressGestureRecognizer() {
        let longPressGestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        longPressGestureRecogniser.minimumPressDuration = 0.25
        collectionView.addGestureRecognizer(longPressGestureRecogniser)
    }
    
//    func setUpTapGestureRecognizer() {
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
//        tapGestureRecognizer.numberOfTapsRequired = 1
//        collectionView.addGestureRecognizer(tapGestureRecognizer)
//    }
    
    func setUpGestureRecognizers() {
//        setUpTapGestureRecognizer()
        setUpLongPressGestureRecognizer()
    }
    
    func configureTimerForReset() {
        headerView.timer.invalidate()
        headerView.resetTimer()
        timerStarted = false
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
        cell.hasMine = (indexPathsOfMines.contains(indexPath))
        cell.delegate = self;
        cell.indexPath = indexPath;
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width / CGFloat(numberOfItemsInSection)) - 2
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    // MARK: Functions handling tap and long press gestures
    
    func cellButtonPressed(indexPath: IndexPath) {
//    func collectionView(_ collectionView: UICollectionView, tappedForCellAt indexPath: IndexPath) {
        if (!timerStarted) {
            indexPathsOfMines = randomlyDistributeMines(indexPathOfInitialCell: indexPath)
            collectionView.reloadItems(at: Array(indexPathsOfMines))
            timerStarted = true
            headerView.timer = Timer.scheduledTimer(timeInterval: 1, target: headerView, selector: #selector(headerView.updateTimer), userInfo: nil, repeats: true)
        }
        let cell: CollectionViewCell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        if cell.hasFlag || cell.uncovered {return}
        if cell.hasMine {
            gameOver(clickedCell: cell)
            return
        }
        let minesInVicinity = numberOfMinesInVicinityOfCell(indexPath)
        if minesInVicinity == 0 {revealSurroundingCellsWithZeroMines(indexPath)}
        cell.configureForMinesInVicinity(numberOfMines: minesInVicinity)
        if isGameWon() {handleGameWon()}
    }
    
    func collectionView(_ collectionView: UICollectionView, longPressForCellAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        if cell.uncovered {return}
        if (remainingFlags > 0 && !cell.hasFlag) {
            cell.hasFlag = true
            remainingFlags -= 1
        }
        else if cell.hasFlag {
            cell.hasFlag = false
            remainingFlags += 1
        }
        cell.configureFlagContainingCell()
        headerView.updateFlagsLabel(numberOfFlags: remainingFlags)
    }
    
//    @objc func handleTap(gesture: UITapGestureRecognizer) {
//        if gesture.state == .ended {
//            let locationOfGesture = gesture.location(in: collectionView)
//            let indexPath = collectionView.indexPathForItem(at: locationOfGesture)
//            if (indexPath != nil) {
//                collectionView(collectionView, tappedForCellAt: indexPath!)
//            }
//        }
//    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let locationOfGesture = gesture.location(in: collectionView)
            let indexPath = collectionView.indexPathForItem(at: locationOfGesture)
            if indexPath != nil {
                collectionView(collectionView, longPressForCellAt: indexPath!)
            }
        }
    }
    
    // MARK: Helper functions
    
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
        return mineIndexPaths
    }
    
    func numberOfMinesInVicinityOfCell(_ indexPath: IndexPath) -> Int {
        return getValidAdjacentIndexPaths(indexPath: indexPath).filter {
            (collectionView.cellForItem(at: $0) as! CollectionViewCell).hasMine
        }.count
    }
    
    func showAllUnflaggedMines() {
        for cell: CollectionViewCell in collectionView!.visibleCells as! Array<CollectionViewCell> {
            if cell.hasMine && !cell.hasFlag {
                cell.configureMineContainingCell()
            }
            else if !cell.hasMine && cell.hasFlag {
                cell.configureForMisplacedFlag()
            }
        }
    }
    
    func disableUserInteractionOnAllCells() {
        for cell: CollectionViewCell in (collectionView!.visibleCells as! Array<CollectionViewCell>) {
            cell.uncovered = true
        }
    }
    
    func gameOver(clickedCell: CollectionViewCell) {
        showAllUnflaggedMines()
        headerView.configureResetButtonForGameOver()
        clickedCell.configureForGameOver()
        disableUserInteractionOnAllCells()
        headerView.timer.invalidate()
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
        let clickedCellCount = (collectionView!.visibleCells as! Array<CollectionViewCell>).filter {
            $0.hasFlag || $0.uncovered
        }.count
        let totalNumberOfCellsInCollectionView = numberOfSections * numberOfItemsInSection
        return clickedCellCount == totalNumberOfCellsInCollectionView - remainingFlags
    }
    
    func handleGameWon() {
        headerView.timer.invalidate()
        headerView.setNumberOfFlagsLabelForGameWon()
        headerView.configureResetButtonForGameWon()
        addFlagsToUncoveredCells()
        let winningTime = headerView.timeLabel.text
        displayGameWonAlert(winningTime: winningTime!)
    }
    
    func displayGameWonAlert(winningTime: String) {
        let alert = UIAlertController(title: "You won!", message: "Your time was \(winningTime) seconds", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "New Game", style: .default, handler: newGameHandler))
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func newGameHandler(alert: UIAlertAction!) {resetGame()}
    
    func addFlagsToUncoveredCells() {
        for cell: CollectionViewCell in (collectionView!.visibleCells as! Array<CollectionViewCell>) {
            if !cell.uncovered {
                cell.hasFlag = true
                cell.configureFlagContainingCell()
            }
        }
    }
    
    func revealSurroundingCellsWithZeroMines(_ indexPath: IndexPath) {
        var indexPathsChecked: Set<IndexPath> = [indexPath]
        var indexPathsWithZeroMines: Set<IndexPath> = [indexPath]
        
        while !indexPathsWithZeroMines.isEmpty {
            var indexPathsToCheck = Set<IndexPath>()
            indexPathsWithZeroMines.forEach {indexPathsToCheck.insert($0)}
            indexPathsWithZeroMines.removeAll()
            indexPathsToCheck.forEach { pathToCheck in
                let adjacentIndexPaths = getValidAdjacentIndexPaths(indexPath: pathToCheck)
                // loop through adjacent index paths which have not already been checked
                adjacentIndexPaths.filter {!indexPathsChecked.contains($0)}
                    .forEach { adjacentIndexPath in
                        let minesInVicinity = numberOfMinesInVicinityOfCell(adjacentIndexPath)
                        indexPathsChecked.insert(adjacentIndexPath)
                        if minesInVicinity == 0 {
                            indexPathsWithZeroMines.insert(adjacentIndexPath)
                        }
                        let cell = collectionView.cellForItem(at: adjacentIndexPath) as! CollectionViewCell
                        cell.configureForMinesInVicinity(numberOfMines: minesInVicinity)
                }
            }
        }
    }
}

