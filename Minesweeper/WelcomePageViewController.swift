//
//  WelcomePageViewController.swift
//  Minesweeper
//
//  Created by Fiona Wilson on 30/03/2019.
//  Copyright © 2019 Fiona Wilson. All rights reserved.
//

import UIKit

class WelcomePageViewController: UIViewController {
    
    
    @IBOutlet weak var beginnerButton: UIButton!
    @IBOutlet weak var intermediateButton: UIButton!
    @IBOutlet weak var advancedButton: UIButton!
    
    
    @IBAction func gameDifficultyChosen(_ sender: Any) {
        performSegue(withIdentifier: "mySegue", sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "mySegue" {
            let button = sender as! UIButton
            let chosenDifficulty = GameDifficulty(rawValue: button.tag)
            let gameViewController = segue.destination as! ViewController
            gameViewController.gameDifficulty = chosenDifficulty
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}




