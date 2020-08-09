//
//  ViewController.swift
//  Minesweeper
//
//  Created by Fiona Wilson on 25/02/2019.
//  Copyright © 2019 Fiona Wilson. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

//enum NumberOfSections: Int {
//    case Beginner = 8
//    case Intermediate = 10
//    case Advanced = 12
//}
//
//enum NumberOfItemsInSection: Int {
//    case Beginner = 8
//    case Intermediate = 9
//    case Advanced = 10
//}

enum NumberOfMines: Int {
    case Beginner = 10
    case Intermediate = 14
    case Advanced = 18
}

enum GameDifficulty: Int {
    case Beginner = 1
    case Intermediate = 2
    case Advanced = 3
}

class GameScreenViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CellSelectionProtocol {
    
    @IBOutlet var headerView: GameScreenHeaderView!
    @IBOutlet weak var collectionView: UICollectionView!
    var indexPathsOfMines = Set<IndexPath>()
    var indexPathsOfFlags = Set<IndexPath>()
    var adjacentIndexPathsWithZeroMinesInVicinity = Set<IndexPath>()
    var gameDifficulty: GameDifficulty?
    var numberOfItemsInSection = 0
    var numberOfSections = 0
    var numberOfMines = 0
    var remainingFlags = 0
    var timerStarted = false
    var managedObjectContext: NSManagedObjectContext?
    let numberOfHighScoresToDisplay = 10
    var audioPlayer: AVAudioPlayer?
    
    var gameLogic = GameLogic()
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        resetGame()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpGame()
        setUpLongPressGestureRecognizer()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer.viewContext
    }
    
    func playSound(_ filename: String) {
        let soundFile = Bundle.main.path(forResource: filename, ofType: nil)!
        let url = URL(fileURLWithPath: soundFile)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        }
        catch {
            print("Sound file \(filename) not found")
        }
    }
    
    func getNumberOfMines(_ gameDifficulty: GameDifficulty) -> Int {
        switch gameDifficulty {
        case .Beginner:
            return NumberOfMines.Beginner.rawValue
        case .Intermediate:
            return NumberOfMines.Intermediate.rawValue
        case .Advanced:
            return NumberOfMines.Advanced.rawValue
        }
    }
    
    func getNumberOfItemsInSection(_ gameDifficulty: GameDifficulty) -> Int {
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
    
    func getNumberOfSections(_ gameDifficulty: GameDifficulty) -> Int {
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
    
    func setUpGame() {
        if let gameDifficulty = gameDifficulty {
            numberOfMines = getNumberOfMines(gameDifficulty)
            numberOfItemsInSection = getNumberOfItemsInSection(gameDifficulty)
            numberOfSections = getNumberOfSections(gameDifficulty)
            remainingFlags = numberOfMines
            headerView.updateFlagsLabel(remainingFlags)
            headerView.configureResetButtonForNewGame()
            indexPathsOfMines = Set<IndexPath>()
            indexPathsOfFlags = Set<IndexPath>()
        }
    }
    
    func resetGame() {
        playSound("click.wav")
        configureTimerForReset()
        setUpGame()
        collectionView.reloadData()
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
        let gridCell = gameLogic.gridCells[indexPath.row][indexPath.section]
        let cell: GameScreenCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier:"CollectionViewCell", for: indexPath) as! GameScreenCollectionViewCell
        cell.hasMine = indexPathsOfMines.contains(indexPath)
        cell.hasFlag = indexPathsOfFlags.contains(indexPath)
        cell.configureFlagImageView()
        cell.delegate = self;
        cell.indexPath = indexPath;
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width / CGFloat(numberOfItemsInSection)) - 2
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    // MARK: CellSelectionProtocol methods
    
    func cellButtonPressed(_ indexPath: IndexPath) {
        if (!timerStarted) {
            indexPathsOfMines = randomlyDistributeMines(indexPathOfInitialCell: indexPath)
            collectionView.reloadItems(at: Array(indexPathsOfMines))
            timerStarted = true
            if let header = headerView {
                header.timer = Timer.scheduledTimer(timeInterval: 1, target: header, selector: #selector(headerView.updateTimer), userInfo: nil, repeats: true)
            }
        }
        let cell: GameScreenCollectionViewCell = collectionView.cellForItem(at: indexPath) as! GameScreenCollectionViewCell
        if cell.hasFlag || cell.uncovered {return}
        if cell.hasMine {
            gameOver(clickedCell: cell)
            return
        }
        let minesInVicinity = numberOfMinesInVicinityOfCell(indexPath)
        if minesInVicinity == 0 {
            revealSurroundingCellsWithZeroMines(indexPath)
        }
        cell.configureForNumberOfMinesInVicinity(minesInVicinity)
        isGameWon() ? handleGameWon() : playSound("click.wav")
    }
    
    // MARK: Long press methods
    
    func setUpLongPressGestureRecognizer() {
        let longPressGestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        longPressGestureRecogniser.minimumPressDuration = 0.25
        collectionView.addGestureRecognizer(longPressGestureRecogniser)
    }
    
    func collectionView(_ collectionView: UICollectionView, longPressForCellAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! GameScreenCollectionViewCell
        if cell.uncovered {return}
        if (remainingFlags == 0 && !cell.hasFlag) {
            presentNoFlagsWarning()
        } else if (remainingFlags > 0 && !cell.hasFlag) {
            cell.hasFlag = true
            indexPathsOfFlags.insert(indexPath)
            remainingFlags -= 1
        }
        else if cell.hasFlag {
            cell.hasFlag = false
            indexPathsOfFlags.remove(indexPath)
            remainingFlags += 1
        }
        cell.configureFlagImageView()
        headerView.updateFlagsLabel(remainingFlags)
        playSound("flag.wav")
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let locationOfGesture = gesture.location(in: collectionView)
            let indexPath = collectionView.indexPathForItem(at: locationOfGesture)
            if let path = indexPath {collectionView(collectionView, longPressForCellAt: path)}
        }
    }
    
    // MARK: Return to welcome screem
    
    @IBAction func homeButtonPressed(_ sender: Any) {
        timerStarted ? presentWarningAlertForReturnToHome() : self.presentingViewController?.dismiss(animated: true, completion:nil)
    }
    
    func presentWarningAlertForReturnToHome() {
        let alert: UIAlertController = UIAlertController.init(title: "Warning!",
                                                              message: "This will quit the game and return to the home screen",
                                                              preferredStyle: .alert)
        let dismissAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        let continueAction = UIAlertAction.init(title: "Quit Game", style: .default) { (action) in
            self.presentingViewController?.dismiss(animated: true, completion:nil)
        }
        alert.addAction(dismissAction)
        alert.addAction(continueAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentNoFlagsWarning() {
        let alert: UIAlertController = UIAlertController.init(title: "No flags left!",
                                                              message: "Remove an existing flag to place it elsewhere",
                                                              preferredStyle: .alert)
        let dismissAction = UIAlertAction.init(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(dismissAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Helper functions
    
    func randomlyDistributeMines(indexPathOfInitialCell: IndexPath) -> Set<IndexPath> {
        var mineIndexPaths = Set<IndexPath>()
        while mineIndexPaths.count < numberOfMines {
            let randomRow = Int.random(in: 0...(numberOfItemsInSection - 1))
            let randomSection = Int.random(in: 0...(numberOfSections - 1))
            let randomIndexPath = IndexPath.init(row: randomRow, section: randomSection)
            if randomIndexPath != indexPathOfInitialCell {
                mineIndexPaths.insert(randomIndexPath)
            }
        }
        return mineIndexPaths
    }
    
    func numberOfMinesInVicinityOfCell(_ indexPath: IndexPath) -> Int {
        return getValidIndexPathsSurroundingCell(indexPath).filter {
            (collectionView.cellForItem(at: $0) as! GameScreenCollectionViewCell).hasMine
        }.count
    }
    
    func showAllUnflaggedMines() {
        for cell: GameScreenCollectionViewCell in collectionView!.visibleCells as! Array<GameScreenCollectionViewCell> {
            if cell.hasMine && !cell.hasFlag {
                cell.configureMineContainingCell()
            }
            else if !cell.hasMine && cell.hasFlag {
                cell.configureForMisplacedFlag()
            }
        }
    }
    
    func disableUserInteractionOnAllCells() {
        for cell: GameScreenCollectionViewCell in (collectionView!.visibleCells as! Array<GameScreenCollectionViewCell>) {
            cell.uncovered = true
        }
    }
    
    func gameOver(clickedCell: GameScreenCollectionViewCell) {
        playSound("game_over.mp3")
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
    
    func isGameWon() -> Bool {
        let clickedCellCount = (collectionView!.visibleCells as! Array<GameScreenCollectionViewCell>).filter {
            $0.hasFlag || $0.uncovered
        }.count
        let totalNumberOfCellsInCollectionView = numberOfSections * numberOfItemsInSection
        return clickedCellCount == totalNumberOfCellsInCollectionView - remainingFlags
    }
    
    func handleGameWon() {
        playSound("game_won.wav")
        headerView.timer.invalidate()
        headerView.setNumberOfFlagsLabelForGameWon()
        headerView.configureResetButtonForGameWon()
        addFlagsToUncoveredCells()
        if let winningTime = headerView.timeLabel.text {
            if let time = Int(winningTime) {
                displayGameWonAlert(winningTime: time)
            }
        }
    }
    
    func displayGameWonAlert(winningTime: Int) {

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = isHighScore(winningTime) ? "New high score!" : "You won!"
        alert.message = "Your time was \(winningTime) seconds"
        
        if (isHighScore(winningTime)) {
            
            alert.addTextField { (textField) in
                textField.placeholder = "Enter your name"
            }
            
            alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
                if let textfields = alert.textFields {
                    if let enteredText = textfields[0].text {
                        let name = (enteredText == "") ? "Anonymous" : enteredText
//                        self.removeLastHighScoreEntry()
                        self.storeHighScore(time: winningTime, name: name)
                        self.performSegue(withIdentifier: "newHighScoreSegue", sender: nil)
                    }
                }
            }))
        } else {
            alert.addAction(UIAlertAction(title: "New Game", style: .default, handler: newGameHandler))
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        }
        present(alert, animated: true)
    }
    
    func storeHighScore(time: Int, name: String) {
        if let context = managedObjectContext {
            let highScores = BestTimesViewController.fetchEntriesForDifficulty(gameDifficultyToStringEnumMapping(gameDifficulty!), context: managedObjectContext)
            if highScores.count >= numberOfHighScoresToDisplay {
                // Update the lowest score with the new values
                if let lowestScore = highScores.last {
                    lowestScore.name = name
                    lowestScore.time = Int32(time)
                }
            } else {
                // No low score exists - create new entry
                let entity = NSEntityDescription.entity(forEntityName: "BestTimeEntry", in: context)
                let newEntry = NSManagedObject(entity: entity!, insertInto: context)
                newEntry.setValue(name, forKey: "name")
                newEntry.setValue(time, forKey: "time")
                newEntry.setValue(gameDifficultyToStringEnumMapping(gameDifficulty), forKey: "difficulty")
            }
            
            do {
                try context.save()
            } catch {
                print("Failed saving")
            }
        }
    }
    
    func isHighScore(_ winningTime: Int) -> Bool {
        if let difficulty = gameDifficulty {
            let highScores = BestTimesViewController.fetchEntriesForDifficulty(gameDifficultyToStringEnumMapping(difficulty), context: managedObjectContext)
            
            if (highScores.count < numberOfHighScoresToDisplay) {return true}
            
            if let lowestStoredEntry = highScores.last {
                return winningTime < lowestStoredEntry.time
            }
        }
        return false
    }
    
    func newGameHandler(alert: UIAlertAction!) {
        resetGame()
    }
    
    func addFlagsToUncoveredCells() {
        for cell: GameScreenCollectionViewCell in (collectionView!.visibleCells as! Array<GameScreenCollectionViewCell>) {
            if !cell.uncovered {
                cell.hasFlag = true
                cell.configureFlagImageView()
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
                let adjacentIndexPaths = getValidIndexPathsSurroundingCell(pathToCheck)
                // loop through adjacent index paths which have not already been checked
                adjacentIndexPaths.filter {!indexPathsChecked.contains($0)}
                    .forEach { adjacentIndexPath in
                        let minesInVicinity = numberOfMinesInVicinityOfCell(adjacentIndexPath)
                        indexPathsChecked.insert(adjacentIndexPath)
                        if minesInVicinity == 0 {
                            indexPathsWithZeroMines.insert(adjacentIndexPath)
                        }
                        let cell = collectionView.cellForItem(at: adjacentIndexPath) as! GameScreenCollectionViewCell
                        if !cell.hasFlag {
                             cell.configureForNumberOfMinesInVicinity(minesInVicinity)
                        }
                }
            }
        }
    }
    
    func gameDifficultyToStringEnumMapping(_ difficulty: GameDifficulty?) -> String {
        if let diff = gameDifficulty {
            switch diff {
            case .Beginner:
                return "Beginner"
            case .Intermediate:
                return "Intermediate"
            case .Advanced:
                return "Advanced"
            }
            
        }
        return ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "newHighScoreSegue" {
            let bestTimesViewController = segue.destination as! BestTimesViewController
            bestTimesViewController.defaultDifficulty = gameDifficultyToStringEnumMapping(gameDifficulty)
        }
    }
}

