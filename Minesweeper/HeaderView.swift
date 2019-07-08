//
//  HeaderView.swift
//  Minesweeper
//
//  Created by Fiona Wilson on 25/02/2019.
//  Copyright © 2019 Fiona Wilson. All rights reserved.
//

import UIKit

class HeaderView: UIView {

    @IBOutlet weak var numberOfFlagsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    var time = 0
    var timer = Timer()
    
    @objc func updateTimer() {
        time += 1
        if timeLabel != nil {timeLabel.text = String(time)}
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
        resetButton.imageView?.image = UIImage(named: "icon-happy-48")
    }
    
    func configureResetButtonForGameOver() {
        resetButton.imageView?.image = UIImage(named: "icon-sad-48")
    }
    
    func configureResetButtonForGameWon() {
        resetButton.imageView?.image = UIImage(named: "icon-cool-48")
    }
}
