//
//  WelcomePageViewController.swift
//  Minesweeper
//
//  Created by Fiona Wilson on 30/03/2019.
//  Copyright © 2019 Fiona Wilson. All rights reserved.
//

import UIKit

class WelcomeScreenViewController: UIViewController {
    
    @IBOutlet weak var beginnerButton: UIButton!
    @IBOutlet weak var intermediateButton: UIButton!
    @IBOutlet weak var advancedButton: UIButton!
    @IBOutlet weak var bestTimesButton: UIButton!
    
   override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBarStyle()
    }
    
    func configureNavigationBarStyle() {
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: Colours.darkBlue,
            NSAttributedString.Key.font: Fonts.navBarTitle
        ]
    }
    
    @IBAction func gameDifficultyChosen(_ sender: Any) {
        performSegue(withIdentifier: Constants.Segues.goToGameScreen, sender: sender)
    }
    
    @IBAction func bestTimesButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: Constants.Segues.viewHighScores, sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == Constants.Segues.goToGameScreen {
            let button = sender as! UIButton
            guard let buttonTitle = button.titleLabel?.text else {return}
            let chosenDifficulty = GameDifficulty(rawValue: buttonTitle)
            let gameViewController = segue.destination as! GameScreenViewController
            gameViewController.gameDifficulty = chosenDifficulty
        }
    }
}
