//
//  BestTimesManager.swift
//  Minesweeper
//
//  Created by Fiona on 10/08/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import Foundation
import CoreData

struct BestTimesManager {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    let numberOfHighScoresToDisplay = 10
    
    func isHighScore(_ winningTime: Int) -> Bool {
//        let highScores = BestTimesViewController.fetchEntriesForDifficulty(gameManager.difficulty.rawValue, context: managedObjectContext)
//
//        if (highScores.count < numberOfHighScoresToDisplay) {return true}
//
//        if let lowestStoredEntry = highScores.last {
//            return winningTime < lowestStoredEntry.time
//        }
        return false
    }
    
    func storeHighScore(time: Int, name: String, difficulty: GameDifficulty) {
        if let context = managedObjectContext {
            let highScores = BestTimesViewController.fetchEntriesForDifficulty(difficulty.rawValue, context: managedObjectContext)
            if highScores.count >= numberOfHighScoresToDisplay {
                // Update the lowest score with the new values
                if let lowestScore = highScores.last {
                    lowestScore.name = name
                    lowestScore.time = Int32(time)
                }
            } else {
                // No low score exists - create new entry
                let entity = NSEntityDescription.entity(forEntityName: "BestTimeEntry", in: context)
                let newEntry = NSManagedObject(entity: entity!, insertInto: context)
                newEntry.setValue(name, forKey: "name")
                newEntry.setValue(time, forKey: "time")
                newEntry.setValue(difficulty.rawValue, forKey: "difficulty")
            }
            
            do {
                try context.save()
            } catch {
                print("Failed saving")
            }
        }
    }
    
}
