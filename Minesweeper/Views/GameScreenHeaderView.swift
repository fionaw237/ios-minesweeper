//
//  HeaderView.swift
//  Minesweeper
//
//  Created by Fiona Wilson on 25/02/2019.
//  Copyright © 2019 Fiona Wilson. All rights reserved.
//

import UIKit

class GameScreenHeaderView: UIView {

    @IBOutlet weak var numberOfFlagsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    var time = 0
    var timer = Timer()
    
    @objc func updateTimer() {
        time += 1
        if let label = timeLabel {
            label.text = String(time)
        }
    }
    
    func resetTimer() {
        time = 0
        timeLabel.text = "0"
    }

    func updateFlagsLabel(_ numberOfFlags: Int) {
        numberOfFlagsLabel.text = String(numberOfFlags)
    }
    
    func setNumberOfFlagsLabelForGameWon() {
        numberOfFlagsLabel.text = "0"
    }
    
    func configureResetButtonForNewGame() {
        resetButton.imageView?.image = UIImage(named: Constants.happyFaceImage)
    }
    
    func configureResetButtonForGameOver() {
        resetButton.imageView?.image = UIImage(named: Constants.sadFaceImage)
    }
    
    func configureResetButtonForGameWon() {
        resetButton.imageView?.image = UIImage(named: Constants.coolFaceImage)
    }
}
