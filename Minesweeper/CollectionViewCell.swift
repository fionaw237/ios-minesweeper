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
        hasMine = false
        hasFlag = false
        uncovered = false
        numberOfMinesLabel.text = ""
        mineOrFlagImageView.image = nil
        backgroundColor = UIColor.lightGray
        isUserInteractionEnabled = true
    }
    
    func configureNumberOfMinesLabel(numberOfMines: Int) {
        numberOfMinesLabel.text = String(numberOfMines)
        numberOfMinesLabel.textColor = getLabelTextColour(numberOfMines: numberOfMines)
    }
    
    func configureMineContainingCell() {
        mineOrFlagImageView.image = UIImage(named: "mine-icon-black-50")
    }
    
    func configureFlagContainingCell() {
        mineOrFlagImageView.image = UIImage(named: "icon-flag-48")
        mineOrFlagImageView.isHidden = !hasFlag
    }
    
    func configureForGameOver() {
        backgroundColor = UIColor.red
    }
    
    func configureForZeroMinesInVicinity() {
       backgroundColor = UIColor.white
    }
    
    func configureForMinesInVicinity(numberOfMines: Int) {
        uncovered = true
        
        if (numberOfMines == 0) {
            configureForZeroMinesInVicinity()
        }
        else {
            configureNumberOfMinesLabel(numberOfMines: numberOfMines)
        }
    }
    
    func configureForMisplacedFlag() {
        mineOrFlagImageView.image = UIImage(named: "icon-cross-48")
    }
    
    func getLabelTextColour(numberOfMines: Int) -> UIColor {
        let labelTextColours = [UIColor.blue, UIColor.green, UIColor.red, UIColor.purple,
                                UIColor.magenta, UIColor.cyan, UIColor.black, UIColor.gray]
        
        return labelTextColours[numberOfMines - 1]
    }
}
