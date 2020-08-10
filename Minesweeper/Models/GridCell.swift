//
//  GridCell.swift
//  Minesweeper
//
//  Created by Fiona on 09/08/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import Foundation

class GridCell {
    var hasMine = false
    var hasFlag = false
    var uncovered = false
    
    func getFlagImageName() -> String? {
        return hasFlag ? Constants.Images.flag : nil
    }
}

