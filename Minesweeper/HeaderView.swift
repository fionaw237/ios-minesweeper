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
        self.time += 1
        if (timeLabel != nil) {
            self.timeLabel.text = String(self.time)
        }
    }
    
    func resetTimer() {
        self.time = 0
        self.timeLabel.text = "0"
    }

    func updateFlagsLabel(numberOfFlags: Int) {
        self.numberOfFlagsLabel.text = String(numberOfFlags)
    }
    
    func configureResetButtonForNewGame() {
        self.resetButton.imageView?.image = UIImage(named: "icon-happy-48")
    }
    
    func configureResetButtonForGameOver() {
        self.resetButton.imageView?.image = UIImage(named: "icon-sad-48")
    }
    
    func configureResetButtonForGameWon() {
        self.resetButton.imageView?.image = UIImage(named: "icon-cool-48")
    }
}
