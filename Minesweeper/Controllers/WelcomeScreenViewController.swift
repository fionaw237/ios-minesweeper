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
    @IBOutlet weak var titleLabel: UILabel!
    
   override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBarStyle()
        animateTitleLabel()
    }
    
    private func configureNavigationBarStyle() {
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: Constants.Colours.navBarTitle,
            NSAttributedString.Key.font: Constants.Fonts.navBarTitle
        ]
    }
    
    private func animateTitleLabel() {
        var charIndex = 0.0
        titleLabel.text = ""
        for letter in Constants.WelcomeScreen.titleLabelText {
            Timer.scheduledTimer(withTimeInterval: 0.15 * charIndex, repeats: false) { (timer) in
                self.titleLabel.text?.append(letter)
            }
            charIndex += 1
        }
    }
    
    @IBAction func gameDifficultyChosen(_ sender: Any) {
        performSegue(withIdentifier: Constants.Segues.goToGameScreen, sender: sender)
    }
    
    @IBAction func bestTimesButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: Constants.Segues.viewBestTimes, sender: sender)
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
