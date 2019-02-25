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
    
    var hasMine: Bool!
    
    override func prepareForReuse() {
        self.hasMine = false
        self.numberOfMinesLabel.text = ""
    }
    
}
