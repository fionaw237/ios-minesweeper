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
    @IBOutlet weak var mineImageView: UIImageView!
    var hasMine: Bool!
    
    override func prepareForReuse() {
        self.hasMine = false
        self.numberOfMinesLabel.text = ""
        self.mineImageView.image = nil
    }
    
    func configureNumberOfMinesLabel(numberOfMines: Int) {
        switch numberOfMines {
        case 0:
            self.numberOfMinesLabel.text = "0"
            self.numberOfMinesLabel.textColor = UIColor.orange
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
        self.mineImageView.image = UIImage(named: "mine-icon-black-50")
    }
}
