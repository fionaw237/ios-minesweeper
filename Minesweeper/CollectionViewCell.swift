//
//  CollectionViewCell.swift
//  Minesweeper
//
//  Created by Fiona Wilson on 25/02/2019.
//  Copyright © 2019 Fiona Wilson. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var numberOfMinesLabel: UILabel!
    @IBOutlet weak var mineOrFlagImageView: UIImageView!
    var hasMine: Bool!
    var hasFlag: Bool!
    
    override func prepareForReuse() {
        self.hasMine = false
        self.hasFlag = false
        self.numberOfMinesLabel.text = ""
        self.mineOrFlagImageView.image = nil
        self.backgroundColor = UIColor.lightGray
        self.isUserInteractionEnabled = true
    }
    
    func configureNumberOfMinesLabel(numberOfMines: Int) {
        switch numberOfMines {
        case 1:
            self.numberOfMinesLabel.text = "1"
            self.numberOfMinesLabel.textColor = UIColor.blue
        case 2:
            self.numberOfMinesLabel.text = "2"
            self.numberOfMinesLabel.textColor = UIColor.green
        case 3:
            self.numberOfMinesLabel.text = "3"
            self.numberOfMinesLabel.textColor = UIColor.red
        case 4:
            self.numberOfMinesLabel.text = "4"
            self.numberOfMinesLabel.textColor = UIColor.purple
        case 5:
            self.numberOfMinesLabel.text = "5"
            self.numberOfMinesLabel.textColor = UIColor.magenta
        case 6:
            self.numberOfMinesLabel.text = "6"
            self.numberOfMinesLabel.textColor = UIColor.cyan
        case 7:
            self.numberOfMinesLabel.text = "7"
            self.numberOfMinesLabel.textColor = UIColor.black
        case 8:
            self.numberOfMinesLabel.text = "8"
            self.numberOfMinesLabel.textColor = UIColor.gray
        default:
            return
        }
    }
    
    func configureMineContainingCell() {
        self.mineOrFlagImageView.image = UIImage(named: "mine-icon-black-50")
    }
    
    func configureFlagContainingCell() {
        self.mineOrFlagImageView.image = UIImage(named: "icon-flag-48")
        self.mineOrFlagImageView.isHidden = !self.hasFlag
    }
    
    func configureForGameOver() {
        self.backgroundColor = UIColor.red
    }
    
    func configureForZeroMinesInVicinity() {
        self.backgroundColor = UIColor.green
    }
    
    func configureForMinesInVicinity(numberOfMines: Int) {
        if (numberOfMines == 0) {
            self.configureForZeroMinesInVicinity()
        }
        else {
            self.configureNumberOfMinesLabel(numberOfMines: numberOfMines)
        }
    }
}
