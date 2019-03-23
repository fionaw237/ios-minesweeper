//
//  HeaderView.swift
//  Minesweeper
//
//  Created by Fiona Wilson on 25/02/2019.
//  Copyright © 2019 Fiona Wilson. All rights reserved.
//

import UIKit

class HeaderView: UIView {

    @IBOutlet weak var numberOfFlagsLabel: UILabel!;
    @IBOutlet weak var timeLabel: UILabel!;
    @IBOutlet weak var resetButton: UIButton!;
    
    func configureResetButtonForGameOver() {
        self.resetButton.imageView?.image = UIImage(named: "icon-sad-48")
    }
}
