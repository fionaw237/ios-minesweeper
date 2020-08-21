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
    var indexPath = IndexPath()
    
    var hasUnflaggedMine: Bool {
        return hasMine && !hasFlag
    }
    
    var hasMisplacedFlag: Bool {
        return !hasMine && hasFlag
    }
    
    var flagImageName: String? {
        return hasFlag ? Constants.Images.flag : nil
    }
    
    init(indexPath: IndexPath) {
        self.indexPath = indexPath
    }
}


