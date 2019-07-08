//
//  CollectionViewCell.swift
//  Minesweeper
//
//  Created by Fiona Wilson on 25/02/2019.
//  Copyright © 2019 Fiona Wilson. All rights reserved.
//

import UIKit

protocol CellSelectionProtocol: class {
    func cellButtonPressed(indexPath: IndexPath)
}

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var numberOfMinesLabel: UILabel!
    @IBOutlet weak var mineOrFlagImageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    var hasMine = false
    var hasFlag = false
    var uncovered = false
    var indexPath: IndexPath? = nil
    weak var delegate: CellSelectionProtocol?
    
    override func prepareForReuse() {
        button.isHidden = false
        hasMine = false
        hasFlag = false
        uncovered = false
        numberOfMinesLabel.text = ""
        mineOrFlagImageView.image = nil
        indexPath = nil
        backgroundColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
        isUserInteractionEnabled = true
    }
    
    func configureNumberOfMinesLabel(numberOfMines: Int) {
        numberOfMinesLabel.text = String(numberOfMines)
        numberOfMinesLabel.textColor = getLabelTextColour(numberOfMines: numberOfMines)
    }
    
    func configureMineContainingCell() {
        mineOrFlagImageView.image = UIImage(named: "mine-icon-black-50")
        button.isHidden = true
    }
    
    func configureFlagContainingCell() {
        mineOrFlagImageView.image = UIImage(named: "icon-flag-48")
        mineOrFlagImageView.isHidden = !hasFlag
    }
    
    func configureForGameOver() {
        backgroundColor = UIColor.red
    }
    
    func configureForZeroMinesInVicinity() {
        backgroundColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
    }
    
    func configureForMinesInVicinity(numberOfMines: Int) {
        button.isHidden = true
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
        button.isHidden = true
    }
    
    func getLabelTextColour(numberOfMines: Int) -> UIColor {
        let labelTextColours = [UIColor.blue, UIColor.green, UIColor.red, UIColor.purple,
                                UIColor.magenta, UIColor.cyan, UIColor.black, UIColor.gray]
        
        return labelTextColours[numberOfMines - 1]
    }
    
    @IBAction func cellButtonTapped(_ sender: Any) {
        if let path = indexPath {
            delegate?.cellButtonPressed(indexPath: path)
        }
    }
}
