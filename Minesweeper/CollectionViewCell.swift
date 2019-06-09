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
    var hasMine = false
    var hasFlag = false
    var uncovered = false
    
    override func prepareForReuse() {
        self.hasMine = false
        self.hasFlag = false
        self.uncovered = false
        self.numberOfMinesLabel.text = ""
        self.mineOrFlagImageView.image = nil
        self.backgroundColor = UIColor.lightGray
        self.isUserInteractionEnabled = true
    }
    
    func configureNumberOfMinesLabel(numberOfMines: Int) {
        
        self.numberOfMinesLabel.text = String(numberOfMines)
        self.numberOfMinesLabel.textColor = self.getLabelTextColour(numberOfMines: numberOfMines)
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
        self.backgroundColor = UIColor.white
    }
    
    func configureForMinesInVicinity(numberOfMines: Int) {
        
        self.uncovered = true
        
        if (numberOfMines == 0) {
            self.configureForZeroMinesInVicinity()
        }
        else {
            self.configureNumberOfMinesLabel(numberOfMines: numberOfMines)
        }
    }
    
    func configureForMisplacedFlag() {
        self.mineOrFlagImageView.image = UIImage(named: "icon-cross-48")
    }
    
    func getLabelTextColour(numberOfMines: Int) -> UIColor {
        
        let labelTextColours = [UIColor.blue, UIColor.green, UIColor.red, UIColor.purple,
                                UIColor.magenta, UIColor.cyan, UIColor.black, UIColor.gray]
        
        return labelTextColours[numberOfMines - 1]
    }
}
