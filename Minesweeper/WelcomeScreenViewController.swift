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
    
    @IBAction func gameDifficultyChosen(_ sender: Any) {
        performSegue(withIdentifier: "mySegue", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "mySegue" {
            let button = sender as! UIButton
            let chosenDifficulty = GameDifficulty(rawValue: button.tag)
            let gameViewController = segue.destination as! GameScreenViewController
            gameViewController.gameDifficulty = chosenDifficulty
        }
    }
}
