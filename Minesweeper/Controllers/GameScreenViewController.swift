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
    @IBOutlet weak var soundsToggle: UIButton!
    
    var gameDifficulty: GameDifficulty?
    private var audioPlayer: AVAudioPlayer?
    
    private var timeManager = TimeManager()
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
        setSoundsToggleImage()
        setUpGame()
        setUpLongPressGestureRecognizer()
        gameManager.delegate = self
        navigationItem.configureBackButton(barButtonSystemItem: .stop, target: self, action: #selector(backButtonPressed(sender:)), colour: Colours.navBarTitle)
    }
    
    
    //MARK:- Navigation
    
    @objc func backButtonPressed(sender: UIBarButtonItem) {
        if timeManager.timerStarted {
            presentWarningAlertForReturnToHome()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func presentWarningAlertForReturnToHome() {
        UIAlertController.alert(
            title: "Warning!",
            message: "This will quit the game and return to the home screen",
            actions: [
                UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil),
                UIAlertAction.init(title: "Quit Game", style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                }
            ]
        ) { self.present($0, animated: true) }
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
        guard let difficulty = gameDifficulty else {
            fatalError("Game difficulty is nil")
        }
        gameManager = GameManager(difficulty: difficulty)
        headerView.updateFlagsLabel(gameManager.remainingFlags)
        headerView.configureResetButtonForNewGame()
    }
    
    private func resetGame() {
        playSound(Constants.Sounds.click)
        
        timeManager.resetTimer() {
            self.headerView.resetTimeLabel()
        }
                
        setUpGame()
        collectionView.reloadData()
    }

    
    
    //MARK:- Sounds
    
    private func playSound(_ filename: String) {
        if UserDefaults.standard.bool(forKey: "soundsOn") {
            let soundFile = Bundle.main.path(forResource: filename, ofType: nil)!
            let url = URL(fileURLWithPath: soundFile)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                // This line will prevent music from another app stopping
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
                audioPlayer?.play()
            }
            catch {
                print("Error with sounds: \(error)")
            }
        }
    }
    
    @IBAction func soundsTogglePressed(_ sender: UIButton) {
        let soundsOn = !UserDefaults.standard.bool(forKey: "soundsOn")
        UserDefaults.standard.set(soundsOn, forKey: "soundsOn")
        setSoundsToggleImage()
    }
    
    private func setSoundsToggleImage() {
        if UserDefaults.standard.object(forKey: "soundsOn") == nil {
            // Used when app is first installed to set the appropriate key for sounds
            UserDefaults.standard.set(true, forKey: "soundsOn")
        }
        if UserDefaults.standard.bool(forKey: "soundsOn") {
            soundsToggle.setImage(UIImage(systemName: "speaker.fill"), for: .normal)
        } else {
            soundsToggle.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
        }
    }
    
    
         
    //MARK:- Long press methods
    
    private func setUpLongPressGestureRecognizer() {
        let longPressGestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        longPressGestureRecogniser.minimumPressDuration = 0.25
        collectionView.addGestureRecognizer(longPressGestureRecogniser)
    }
    
    private func collectionView(_ collectionView: UICollectionView, longPressForCellAt indexPath: IndexPath) {
        let gridCell = gameManager.gridCellForIndexPath(indexPath)
        if gridCell.uncovered {
            return
        }
        gameManager.setCellPropertiesAfterLongPress(for: indexPath)
        
        let cell = collectionView.cellForItem(at: indexPath) as! GameScreenCollectionViewCell
        cell.configureFlagImageView(gridCell.flagImageName)
        
        headerView.updateFlagsLabel(gameManager.remainingFlags)
        playSound(Constants.Sounds.flag)
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let locationOfGesture = gesture.location(in: collectionView)
            let indexPath = collectionView.indexPathForItem(at: locationOfGesture)
            if let path = indexPath {
                collectionView(collectionView, longPressForCellAt: path)
            }
        }
    }
    
    
    //MARK:- Methods handling cell display
    
    private func showAllUnflaggedMines() {
        for gridCell in gameManager.gridCellsWithUnflaggedMine {
            let collectionViewCell = collectionView.cellForItem(at: gridCell.indexPath) as! GameScreenCollectionViewCell
            collectionViewCell.configureMineContainingCell()
        }
    }
    
    private func showMisplacedFlags() {
        for gridCell in gameManager.gridCellsWithMisplacedFlag {
            let collectionViewCell = collectionView.cellForItem(at: gridCell.indexPath) as! GameScreenCollectionViewCell
            collectionViewCell.configureForMisplacedFlag()
        }
    }
    
    private func addFlagsToUncoveredCells() {
        for gridCell in gameManager.uncoveredCells {
            gameManager.addFlag(to: gridCell)
            let collectionViewCell = collectionView.cellForItem(at: gridCell.indexPath) as! GameScreenCollectionViewCell
            collectionViewCell.configureFlagImageView(Constants.Images.flag)
        }
    }    
    
    //MARK:- Methods handling game over/game won
    
    private func gameOver(clickedCell: GameScreenCollectionViewCell) {
        playSound(Constants.Sounds.gameOver)
        showAllUnflaggedMines()
        showMisplacedFlags()
        headerView.configureResetButtonForGameOver()
        clickedCell.configureForGameOver()
        gameManager.disableUserInteractionOnAllCells()
        timeManager.stopTimer()
    }
    
    private func handleGameWon() {
        playSound(Constants.Sounds.gameWon)
        timeManager.stopTimer()
        headerView.setNumberOfFlagsLabelForGameWon()
        headerView.configureResetButtonForGameWon()
        addFlagsToUncoveredCells()
        gameManager.disableUserInteractionOnAllCells()
        displayGameWonAlert(winningTime: timeManager.time)
    }
    
    private func displayGameWonAlert(winningTime: Int) {
        
        let newHighScore = bestTimesManager.isHighScore(winningTime, difficulty: gameManager.difficulty)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = newHighScore ? "New high score!" : "You won!"
        alert.message = "Your time was \(TimeManager.convertSecondsToMinutesAndSeconds(winningTime))"
        
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
        let gridCell = gameManager.gridCellForIndexPath(indexPath)
        
        let cell: GameScreenCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier:"CollectionViewCell", for: indexPath) as! GameScreenCollectionViewCell
        cell.configureFlagImageView(gridCell.flagImageName)
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


//MARK:- CellSelectionDelegate and related helper methods

extension GameScreenViewController: CellSelectionDelegate {
    
    func cellButtonPressed(_ indexPath: IndexPath) {
        if (!timeManager.timerStarted) {
            handleFirstCellPressed(indexPath)
        }
        
        let gridCell = gameManager.gridCellForIndexPath(indexPath)
        if gridCell.hasFlag || gridCell.uncovered {
            return
        }
        gridCell.uncovered = true
        
        let collectionViewCell = collectionView.cellForItem(at: indexPath) as! GameScreenCollectionViewCell
        
        if gridCell.hasMine {
            gameOver(clickedCell: collectionViewCell)
            return
        }
        
        let minesInVicinity = gameManager.numberOfMinesInVicinityOfCell(indexPath)
        if minesInVicinity == 0 {
            handleZeroMinesInVicinityOfCell(at: indexPath)
        }
        
        collectionViewCell.configureForNumberOfMinesInVicinity(minesInVicinity)
        gameManager.isGameWon() ? handleGameWon() : playSound(Constants.Sounds.click)
    }
    
    private func handleFirstCellPressed(_ indexPath: IndexPath) {
        gameManager.randomlyDistributeMines(indexPathOfInitialCell: indexPath)
        timeManager.scheduletimer { timer in
            self.headerView.timeLabel.text = self.timeManager.getUpdatedTime()
        }
    }
    
    private func handleZeroMinesInVicinityOfCell(at indexPath: IndexPath) {
        // Create a dictionary with key = indexPath, value = number of mines in vicinity of that indexPath
        let indexPathsToRevealDict = gameManager.findCellsToReveal(indexPath)
        
        indexPathsToRevealDict.forEach { (indexPath, numberOfMines) in
            let cellToReveal = collectionView.cellForItem(at: indexPath) as! GameScreenCollectionViewCell
            cellToReveal.configureForNumberOfMinesInVicinity(numberOfMines)
        }
    }
    
}


//MARK:- GameAlertDelegate methods

extension GameScreenViewController: GameAlertDelegate {
    func presentNoFlagsWarning() {
        UIAlertController.alert(
            title: "No flags left!",
            message: "Remove an existing flag to place it elsewhere",
            actions: [UIAlertAction.init(title: "Okay", style: .cancel, handler: nil) ]
        ) { self.present($0, animated: true) }
    }
}
