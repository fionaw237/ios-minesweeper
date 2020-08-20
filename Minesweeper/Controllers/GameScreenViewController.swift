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
    private var audioPlayer: AVAudioPlayer?
    private var gameManager = GameManager()
    private var bestTimesManager = BestTimesManager(
        context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    )
    
    
    //MARK:- Lifecycle methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpGame()
        setUpLongPressGestureRecognizer()
        gameManager.delegate = self
    }
    
    
    //MARK:- Navigation
        
    // TODO: implement this with nav bar back button
    @IBAction func homeButtonPressed(_ sender: Any) {
        gameManager.timerStarted ? presentWarningAlertForReturnToHome() : self.presentingViewController?.dismiss(animated: true, completion:nil)
    }
    
    private func presentWarningAlertForReturnToHome() {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == Constants.Segues.newHighScore {
            let bestTimesViewController = segue.destination as! BestTimesViewController
            bestTimesViewController.defaultDifficulty = gameManager.difficulty.rawValue
        }
    }
    
    //MARK:- Methods handling game reset/setup
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        resetGame()
    }
    
    private func setUpGame() {
        if let gameDifficulty = gameDifficulty {
            gameManager = GameManager(difficulty: gameDifficulty)
            headerView.updateFlagsLabel(gameManager.remainingFlags)
            headerView.configureResetButtonForNewGame()
        }
    }
    
    private func resetGame() {
        playSound(Constants.Sounds.click)
        configureTimerForReset()
        setUpGame()
        collectionView.reloadData()
    }
    
    private func configureTimerForReset() {
        headerView.timer.invalidate()
        headerView.resetTimer()
        gameManager.timerStarted = false
    }
    
    
    //MARK:- Sounds
    
    private func playSound(_ filename: String) {
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
    
         
    //MARK:- Long press methods
    
    private func setUpLongPressGestureRecognizer() {
        let longPressGestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        longPressGestureRecogniser.minimumPressDuration = 0.25
        collectionView.addGestureRecognizer(longPressGestureRecogniser)
    }
    
    private func collectionView(_ collectionView: UICollectionView, longPressForCellAt indexPath: IndexPath) {
        let gridCell = gameManager.gridCells[indexPath.row][indexPath.section]
        if gridCell.uncovered {return}
        gameManager.setCellPropertiesAfterLongPress(for: indexPath)
        let cell = collectionView.cellForItem(at: indexPath) as! GameScreenCollectionViewCell
        cell.configureFlagImageView(gridCell.getFlagImageName())
        headerView.updateFlagsLabel(gameManager.remainingFlags)
        playSound(Constants.Sounds.flag)
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let locationOfGesture = gesture.location(in: collectionView)
            let indexPath = collectionView.indexPathForItem(at: locationOfGesture)
            if let path = indexPath {collectionView(collectionView, longPressForCellAt: path)}
        }
    }
    
    
    //MARK:- Methods handling cell display
    
    private func showAllUnflaggedMines() {
        for gridCell in gameManager.getGridCellsWithUnflaggedMines() {
            let collectionViewCell = collectionView.cellForItem(at: gridCell.indexPath) as! GameScreenCollectionViewCell
            collectionViewCell.configureMineContainingCell()
        }
    }
    
    private func showMisplacedFlags() {
        for gridCell in gameManager.getGridCellsWithMisplacedFlags() {
            let collectionViewCell = collectionView.cellForItem(at: gridCell.indexPath) as! GameScreenCollectionViewCell
            collectionViewCell.configureForMisplacedFlag()
        }
    }
    
    private func addFlagsToUncoveredCells() {
        for indexPath in gameManager.getUncoveredCells() {
            let collectionViewCell = collectionView.cellForItem(at: indexPath) as! GameScreenCollectionViewCell
            collectionViewCell.configureFlagImageView(Constants.Images.flag)
        }
    }
    
    private func disableUserInteractionOnAllCells() {
        gameManager.get1DGridCellsArray().forEach {$0.uncovered = true}
    }
    
    
    //MARK:- Methods handling game over/game won
    
    private func gameOver(clickedCell: GameScreenCollectionViewCell) {
        playSound(Constants.Sounds.gameOver)
        showAllUnflaggedMines()
        showMisplacedFlags()
        headerView.configureResetButtonForGameOver()
        clickedCell.configureForGameOver()
        disableUserInteractionOnAllCells()
        headerView.timer.invalidate()
    }
    
    private func handleGameWon() {
        playSound(Constants.Sounds.gameWon)
        headerView.timer.invalidate()
        headerView.setNumberOfFlagsLabelForGameWon()
        headerView.configureResetButtonForGameWon()
        addFlagsToUncoveredCells()
        if let winningTime = headerView.timeLabel.text, let time = Int(winningTime) {
            displayGameWonAlert(winningTime: time)
        }
    }
    
    private func displayGameWonAlert(winningTime: Int) {
        
        let newHighScore = bestTimesManager.isHighScore(winningTime, difficulty: gameManager.difficulty)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = newHighScore ? "New high score!" : "You won!"
        alert.message = "Your time was \(winningTime) seconds"
        
        if newHighScore {
            alert.addTextField { textField in
                textField.placeholder = "Enter your name"
            }
            
            alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { action in
                if let enteredText = alert.textFields?[0].text {
                    let name = (enteredText == "") ? "Anonymous" : enteredText
                    self.bestTimesManager.storeHighScore(time: winningTime, name: name, difficulty: self.gameManager.difficulty)
                    self.performSegue(withIdentifier: Constants.Segues.newHighScore, sender: nil)
                }
            }))
        } else {
            alert.addAction(UIAlertAction(title: "New Game", style: .default, handler: newGameHandler))
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        }
        
        present(alert, animated: true)
    }
    
    private func newGameHandler(alert: UIAlertAction!) {
        resetGame()
    }
    
}


//MARK:- Collection view delegate methods

extension GameScreenViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return gameManager.numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameManager.numberOfItemsInSection
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let gridCell = gameManager.gridCells[indexPath.row][indexPath.section]
        gridCell.hasMine = gameManager.indexPathsOfMines.contains(indexPath)

        let cell: GameScreenCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier:"CollectionViewCell", for: indexPath) as! GameScreenCollectionViewCell
        cell.configureFlagImageView(gridCell.getFlagImageName())
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
    
    // UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width / CGFloat(gameManager.numberOfItemsInSection)) - 2
        return CGSize(width: cellWidth, height: cellWidth)
    }
}


//MARK:- CellSelectionDelegate methods

extension GameScreenViewController: CellSelectionDelegate {
    func cellButtonPressed(_ indexPath: IndexPath) {
        if (!gameManager.timerStarted) {
            gameManager.randomlyDistributeMines(indexPathOfInitialCell: indexPath)
            collectionView.reloadItems(at: Array(gameManager.indexPathsOfMines))
            gameManager.timerStarted = true
            headerView.timer = Timer.scheduledTimer(timeInterval: 1, target: headerView!, selector: #selector(headerView.updateTimer), userInfo: nil, repeats: true)
        }
        
        let gridCell = gameManager.gridCells[indexPath.row][indexPath.section]
        if gridCell.hasFlag || gridCell.uncovered {return}
        gridCell.uncovered = true
        
        let collectionViewCell = collectionView.cellForItem(at: indexPath) as! GameScreenCollectionViewCell
        
        if gridCell.hasMine {
            gameOver(clickedCell: collectionViewCell)
            return
        }
        
        let minesInVicinity = gameManager.numberOfMinesInVicinityOfCell(indexPath)
        if minesInVicinity == 0 {
            let indexPathsToRevealDict = gameManager.findCellsToReveal(indexPath)
            for item in indexPathsToRevealDict {
                let cellToReveal = collectionView.cellForItem(at: item.key) as! GameScreenCollectionViewCell
                cellToReveal.configureForNumberOfMinesInVicinity(item.value)
            }
        }
        collectionViewCell.configureForNumberOfMinesInVicinity(minesInVicinity)
        gameManager.isGameWon() ? handleGameWon() : playSound(Constants.Sounds.click)
    }
}


//MARK:- GameAlertDelegate methods

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
