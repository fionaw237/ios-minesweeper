//
//  BestTimesViewController.swift
//  Minesweeper
//
//  Created by Fiona Wilson on 20/08/2019.
//  Copyright © 2019 Fiona Wilson. All rights reserved.
//

import UIKit
import CoreData

class BestTimesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var bestTimesTableView: UITableView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var pickerData = ["Beginner", "Intermediate", "Advanced"]
    var bestTimes: [BestTimeEntry] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var managedObjectContext: NSManagedObjectContext?
    var defaultDifficulty = "Beginner"
    
    override func viewDidLoad() {
        managedObjectContext = appDelegate.persistentContainer.viewContext
        bestTimes = BestTimesViewController.fetchEntriesForDifficulty(defaultDifficulty, context: managedObjectContext)
        setSelectedDifficultyInPickerView()
    }
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion:nil)
    }
    
    func setSelectedDifficultyInPickerView() {
        if let rowToSelect = pickerData.firstIndex(of: defaultDifficulty) {
            pickerView.selectRow(rowToSelect, inComponent: 0, animated: true)
        }
    }
    
    // MARK: table view delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bestTimes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BestTimesTableViewCell.self), for: indexPath) as! BestTimesTableViewCell
        cell.configure(row:indexPath.row, timeEntry:bestTimes[indexPath.row])
        return cell
    }
    
    // MARK: picker view delegate methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: pickerData[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0:
            bestTimes = BestTimesViewController.fetchEntriesForDifficulty("Beginner", context: managedObjectContext)
            break
        case 1:
            bestTimes = BestTimesViewController.fetchEntriesForDifficulty("Intermediate", context: managedObjectContext)
            break
        case 2:
            bestTimes = BestTimesViewController.fetchEntriesForDifficulty("Advanced", context: managedObjectContext)
            break
        default:
            break
        }
        bestTimesTableView.reloadData()
    }
    
    // MARK: core data fetch
    
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
    
    // MARK: Core data delete all
    
    @IBAction func ResetAllBestTimesButtonPressed(_ sender: Any) {
        if let context = managedObjectContext {
            if scoresAreNotEmpty(context) {
                let alert: UIAlertController = UIAlertController.init(title: "Are you sure you want to reset all best times?",
                                                                      message: nil,
                                                                      preferredStyle: .alert)
                let dismissAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
                let continueAction = UIAlertAction.init(title: "Reset All", style: .default) { (action) in
                    self.resetAllBestTimes(context)
                }
                alert.addAction(dismissAction)
                alert.addAction(continueAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func resetAllBestTimes(_ context: NSManagedObjectContext) {
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
        bestTimes = BestTimesViewController.fetchEntriesForDifficulty(defaultDifficulty, context: managedObjectContext)
        bestTimesTableView.reloadData()
    }
    
    private func scoresAreNotEmpty(_ context: NSManagedObjectContext) -> Bool {
        for difficulty in pickerData {
            if !BestTimesViewController.fetchEntriesForDifficulty(difficulty, context: context).isEmpty {
                return true
            }
        }
        return false
    }
    
}
