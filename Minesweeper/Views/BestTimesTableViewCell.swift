//
//  BestTimesTableViewCell.swift
//  Minesweeper
//
//  Created by Fiona Wilson on 20/08/2019.
//  Copyright © 2019 Fiona Wilson. All rights reserved.
//

import UIKit

class BestTimesTableViewCell: UITableViewCell {

    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    func configure(row: Int, timeEntry: BestTimeEntry) {
        positionLabel.text = "\(row + 1)"
        nameLabel.text = timeEntry.name
        timeLabel.text = "\(TimeManager.convertSecondsToMinutesAndSeconds(Int(timeEntry.time)))"
    }
}
