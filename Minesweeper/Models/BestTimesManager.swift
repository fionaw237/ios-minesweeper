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
    
    static func resetAllBestTimes(_ context: NSManagedObjectContext) {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "BestTimeEntry")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try context.execute(deleteRequest)
            try context.save()
        }
        catch
        {
            print ("There was an error deleting best times")
        }
    }
    
    static func fetchEntriesForDifficulty(_ difficulty: String, context: NSManagedObjectContext?) -> [BestTimeEntry] {
        if let ctx = context {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "BestTimeEntry")
            request.predicate = NSPredicate(format: "difficulty == %@", difficulty)
            request.returnsObjectsAsFaults = false
            do {
                let results = try ctx.fetch(request) as! [BestTimeEntry]
                return results.sorted(by: {$0.time < $1.time})
            } catch {
               print("fetch failed for high scores")
            }
        }
        return []
    }
    
    func isHighScore(_ winningTime: Int, difficulty: GameDifficulty) -> Bool {
        let highScores = BestTimesManager.fetchEntriesForDifficulty(difficulty.rawValue, context: managedObjectContext)

        if (highScores.count < numberOfHighScoresToDisplay) {return true}

        if let lowestStoredEntry = highScores.last {
            return winningTime < lowestStoredEntry.time
        }
        return false
    }
    
    func storeHighScore(time: Int, name: String, difficulty: GameDifficulty) {
        if let context = managedObjectContext {
            let highScores = BestTimesManager.fetchEntriesForDifficulty(difficulty.rawValue, context: managedObjectContext)
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
