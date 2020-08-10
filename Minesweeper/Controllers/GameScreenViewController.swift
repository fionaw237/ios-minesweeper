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

class GameScreenViewController: UIViewController {
    
    @IBOutlet var headerView: GameScreenHeaderView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var gameDifficulty: GameDifficulty?
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
        
        gameLogic.delegate = self
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
    
    func setUpGame() {
        if let gameDifficulty = gameDifficulty {
            gameLogic = GameLogic(difficulty: gameDifficulty)
            headerView.updateFlagsLabel(gameLogic.remainingFlags)
            headerView.configureResetButtonForNewGame()
        }
    }
    
    func resetGame() {
        playSound(Constants.Sounds.click)
        configureTimerForReset()
        setUpGame()
        collectionView.reloadData()
    }
    
    func configureTimerForReset() {
        headerView.timer.invalidate()
        headerView.resetTimer()
        gameLogic.timerStarted = false
    }
         
    // MARK: Long press methods
    
    func setUpLongPressGestureRecognizer() {
        let longPressGestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        longPressGestureRecogniser.minimumPressDuration = 0.25
        collectionView.addGestureRecognizer(longPressGestureRecogniser)
    }
    
    func collectionView(_ collectionView: UICollectionView, longPressForCellAt indexPath: IndexPath) {
        let gridCell = gameLogic.gridCells[indexPath.row][indexPath.section]
        if gridCell.uncovered {return}
        gameLogic.setCellPropertiesAfterLongPress(for: indexPath)
        let cell = collectionView.cellForItem(at: indexPath) as! GameScreenCollectionViewCell
        cell.configureFlagImageView(gridCell.getFlagImageName())
        headerView.updateFlagsLabel(gameLogic.remainingFlags)
        playSound(Constants.Sounds.flag)
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
        gameLogic.timerStarted ? presentWarningAlertForReturnToHome() : self.presentingViewController?.dismiss(animated: true, completion:nil)
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
    
    
    func showAllUnflaggedMines() {
        
        for row in 0..<gameLogic.numberOfItemsInSection {
            for section in 0..<gameLogic.numberOfSections {
                let indexPath = IndexPath(row: row, section: section)
                let gridCell = gameLogic.gridCells[indexPath.row][indexPath.section]
                
                let collectionViewCell: GameScreenCollectionViewCell = collectionView.cellForItem(at: indexPath) as! GameScreenCollectionViewCell
                
                if gridCell.hasMine && !gridCell.hasFlag {
                    collectionViewCell.configureMineContainingCell()
                }
                else if !gridCell.hasMine && gridCell.hasFlag {
                    collectionViewCell.configureForMisplacedFlag()
                }
            }
        }

    }
    
    func disableUserInteractionOnAllCells() {
        for cell in gameLogic.get1DGridCellsArray() {
            cell.uncovered = true
        }
    }
    
    func gameOver(clickedCell: GameScreenCollectionViewCell) {
        playSound(Constants.Sounds.gameOver)
        showAllUnflaggedMines()
        headerView.configureResetButtonForGameOver()
        clickedCell.configureForGameOver()
        disableUserInteractionOnAllCells()
        headerView.timer.invalidate()
    }
    
    func isGameWon() -> Bool {
        let clickedCellCount = gameLogic.get1DGridCellsArray().filter {
            $0.hasFlag || $0.uncovered
        }.count
        return clickedCellCount == gameLogic.getTotalNumberOfCells() - gameLogic.remainingFlags
    }
    
    func handleGameWon() {
        playSound(Constants.Sounds.gameWon)
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
                        self.performSegue(withIdentifier: Constants.Segues.newHighScore, sender: nil)
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
            let highScores = BestTimesViewController.fetchEntriesForDifficulty(gameLogic.difficulty.rawValue, context: managedObjectContext)
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
                newEntry.setValue(gameLogic.difficulty.rawValue, forKey: "difficulty")
            }
            
            do {
                try context.save()
            } catch {
                print("Failed saving")
            }
        }
    }
    
    func isHighScore(_ winningTime: Int) -> Bool {
        let highScores = BestTimesViewController.fetchEntriesForDifficulty(gameLogic.difficulty.rawValue, context: managedObjectContext)
        
        if (highScores.count < numberOfHighScoresToDisplay) {return true}
        
        if let lowestStoredEntry = highScores.last {
            return winningTime < lowestStoredEntry.time
        }
        return false
    }
    
    func newGameHandler(alert: UIAlertAction!) {
        resetGame()
    }
    
    func addFlagsToUncoveredCells() {
//        for cell: GameScreenCollectionViewCell in (collectionView!.visibleCells as! Array<GameScreenCollectionViewCell>) {
//            if !cell.uncovered {
//                cell.hasFlag = true
//                cell.configureFlagImageView()
//            }
//        }
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == Constants.Segues.newHighScore {
            let bestTimesViewController = segue.destination as! BestTimesViewController
            bestTimesViewController.defaultDifficulty = gameLogic.difficulty.rawValue
        }
    }
}

extension GameScreenViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return gameLogic.numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameLogic.numberOfItemsInSection
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let gridCell = gameLogic.gridCells[indexPath.row][indexPath.section]
        gridCell.hasMine = gameLogic.indexPathsOfMines.contains(indexPath)

        let cell: GameScreenCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier:"CollectionViewCell", for: indexPath) as! GameScreenCollectionViewCell
        cell.configureFlagImageView(gridCell.getFlagImageName())
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
}

extension GameScreenViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width / CGFloat(gameLogic.numberOfItemsInSection)) - 2
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

extension GameScreenViewController: CellSelectionProtocol {
    func cellButtonPressed(_ indexPath: IndexPath) {
        if (!gameLogic.timerStarted) {
            gameLogic.randomlyDistributeMines(indexPathOfInitialCell: indexPath)
            collectionView.reloadItems(at: Array(gameLogic.indexPathsOfMines))
            gameLogic.timerStarted = true
            if let header = headerView {
                header.timer = Timer.scheduledTimer(timeInterval: 1, target: header, selector: #selector(headerView.updateTimer), userInfo: nil, repeats: true)
            }
        }
        
        let cell: GameScreenCollectionViewCell = collectionView.cellForItem(at: indexPath) as! GameScreenCollectionViewCell
        
        let gridCell = gameLogic.gridCells[indexPath.row][indexPath.section]
        if gridCell.hasFlag || gridCell.uncovered {return}
        gridCell.uncovered = true
        if gridCell.hasMine {
            gameOver(clickedCell: cell)
            return
        }
        
        let minesInVicinity = gameLogic.numberOfMinesInVicinityOfCell(indexPath)
        if minesInVicinity == 0 {
            let indexPathsToRevealDict = gameLogic.findCellsToReveal(indexPath)
            for item in indexPathsToRevealDict {
                let cellToReveal = collectionView.cellForItem(at: item.key) as! GameScreenCollectionViewCell
                cellToReveal.configureForNumberOfMinesInVicinity(item.value)
            }
        }
        cell.configureForNumberOfMinesInVicinity(minesInVicinity)
        isGameWon() ? handleGameWon() : playSound(Constants.Sounds.click)
    }
}

extension GameScreenViewController: GameAlertDelegate {
    func presentNoFlagsWarning() {
        let alert: UIAlertController = UIAlertController.init(title: "No flags left!",
                                                              message: "Remove an existing flag to place it elsewhere",
                                                              preferredStyle: .alert)
        let dismissAction = UIAlertAction.init(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(dismissAction)
        self.present(alert, animated: true, completion: nil)
    }
}
