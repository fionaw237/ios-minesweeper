//
//  BestTimesManager.swift
//  Minesweeper
//
//  Created by Fiona on 10/08/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import CoreData

struct BestTimesManager {
    
    var context: NSManagedObjectContext? = nil
    private let numberOfHighScoresToDisplay = Constants.HighScores.numberOfHighScoresToDisplay
    
    func resetAllBestTimes() {
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "BestTimeEntry")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        guard let context = context else {
            fatalError("The managed object context is nil")
        }
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        }
        catch {
            print ("Error deleting best times: \(error)")
        }
    }
    
    func fetchEntriesForDifficulty(_ difficulty: String) -> [BestTimeEntry] {
        
        guard let context = context else {
            fatalError("The managed object context is nil")
        }
        
        let request: NSFetchRequest<BestTimeEntry> = BestTimeEntry.fetchRequest()
        request.predicate = NSPredicate(format: "difficulty == %@", difficulty)
        
        do {
            let results = try context.fetch(request)
            return results.sorted(by: {$0.time < $1.time})
        } catch {
            print("Error fetching high scores: \(error)")
        }
        
        return []
    }
    
    func isHighScore(_ winningTime: Int, difficulty: GameDifficulty) -> Bool {
        
        let highScores = fetchEntriesForDifficulty(difficulty.rawValue)

        if (highScores.count < numberOfHighScoresToDisplay) {
            return true
        }

        if let lowestStoredEntry = highScores.last {
            return winningTime < lowestStoredEntry.time
        }
        
        return false
    }
    
    func storeHighScore(time: Int, name: String, difficulty: GameDifficulty) {
        
        guard let context = context else {
            fatalError("The managed object context is nil")
        }
        
        let highScores = fetchEntriesForDifficulty(difficulty.rawValue)
        
        if highScores.count >= numberOfHighScoresToDisplay {
            // Update the lowest score with the new values
            if let lowestScore = highScores.last {
                lowestScore.name = name
                lowestScore.time = Int32(time)
            }
        } else {
            // No low score exists - create new entry
            let newEntry = BestTimeEntry(context: context)
            newEntry.name = name
            newEntry.time = Int32(time)
            newEntry.difficulty = difficulty.rawValue
        }
        
        do {
            try context.save()
        } catch {
            print("Error saving to context: \(error)")
        }
    }
    
}
