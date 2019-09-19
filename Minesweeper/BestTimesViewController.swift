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
    
    override func viewDidLoad() {
        managedObjectContext = appDelegate.persistentContainer.viewContext
        fetchEntriesForDifficulty("Beginner")
    }
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion:nil)
    }
    
    // MARK: table view delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bestTimes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BestTimesTableViewCell.self), for: indexPath) as! BestTimesTableViewCell
        cell.nameLabel.text = bestTimes[indexPath.row].name
        cell.timeLabel.text = bestTimes[indexPath.row].time
        return cell
    }
    
    // MARK: picker view delegate methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0:
            fetchEntriesForDifficulty("Beginner")
            break
        case 1:
            fetchEntriesForDifficulty("Intermediate")
            break
        case 2:
            fetchEntriesForDifficulty("Advanced")
            break
        default:
            break
        }
        bestTimesTableView.reloadData()
    }
    
    func fetchEntriesForDifficulty(_ difficulty: String) {
        if let context = managedObjectContext {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "BestTimeEntry")
            request.predicate = NSPredicate(format: "difficulty == %@", difficulty)
            request.returnsObjectsAsFaults = false
            do {
                bestTimes = try context.fetch(request) as! [BestTimeEntry]
            } catch {
                print("Failed")
            }
        }
        
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
