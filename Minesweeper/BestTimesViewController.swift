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
    
//    func clearAllSavedData() {
////         create the delete request for the specified entity
//                let fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "BestTimeEntry")
//                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//
//                // get reference to the persistent container
//                let persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
//
//                // perform the delete
//                do {
//                    try persistentContainer.viewContext.execute(deleteRequest)
//                } catch let error as NSError {
//                    print(error)
//                }
//    }
}
