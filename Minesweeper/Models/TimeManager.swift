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
    
    static func convertSecondsToMinutesAndSeconds(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        
        let minutesString = (minutes < 10) ? "0\(minutes)" : "\(minutes)"
        let secondsString = (remainingSeconds < 10) ? "0\(remainingSeconds)" : "\(remainingSeconds)"
        
        return "\(minutesString):\(secondsString)"
    }
    
    mutating func scheduletimer(_ callback: @escaping (Timer) -> Void) {
        timerStarted = true
        time = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: callback)
    }
    
    mutating func getUpdatedTime() -> String {
        time += 1
        return TimeManager.convertSecondsToMinutesAndSeconds(time)
    }
    
    mutating func resetTimer(_ callback: () -> Void) {
        timer.invalidate()
        timerStarted = false
        callback()
    }
    
    func stopTimer() {
        timer.invalidate()
    }
}
