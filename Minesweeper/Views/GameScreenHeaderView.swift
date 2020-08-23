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
    
    func resetTimeLabel() {
        timeLabel.text = "00:00"
    }

    func updateFlagsLabel(_ numberOfFlags: Int) {
        numberOfFlagsLabel.text = String(numberOfFlags)
    }
    
    func setNumberOfFlagsLabelForGameWon() {
        numberOfFlagsLabel.text = "0"
    }
    
    func configureResetButtonForNewGame() {
        resetButton.imageView?.image = UIImage(named: Constants.Images.happyFace)
    }
    
    func configureResetButtonForGameOver() {
        resetButton.imageView?.image = UIImage(named: Constants.Images.sadFace)
    }
    
    func configureResetButtonForGameWon() {
        resetButton.imageView?.image = UIImage(named: Constants.Images.coolFace)
    }
}
