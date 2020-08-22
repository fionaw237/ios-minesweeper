//
//  TimeManager.swift
//  Minesweeper
//
//  Created by Fiona on 22/08/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import Foundation

struct TimeManager {
    var timer = Timer()
    var time = 0
    var timerStarted = false
    
    mutating func scheduletimer(_ callback: @escaping (Timer) -> Void) {
        timerStarted = true
        time = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: callback)
    }
}
