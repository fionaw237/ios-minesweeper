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
    
    @IBOutlet weak var bestTimesTableView: UITableView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var bestTimesManager: BestTimesManager? = nil
    
    var pickerData = ["Beginner", "Intermediate", "Advanced"]
    var bestTimes: [BestTimeEntry] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var managedObjectContext: NSManagedObjectContext?
    var defaultDifficulty = "Beginner"
    
    override func viewDidLoad() {
        managedObjectContext = appDelegate.persistentContainer.viewContext
        
        if bestTimesManager == nil {
            bestTimesManager = BestTimesManager(
                context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            )
        }
        
        bestTimes = bestTimesManager!.fetchEntriesForDifficulty(defaultDifficulty)
        setSelectedDifficultyInPickerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
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
            bestTimes = bestTimesManager!.fetchEntriesForDifficulty("Beginner")
            break
        case 1:
            bestTimes = bestTimesManager!.fetchEntriesForDifficulty("Intermediate")
            break
        case 2:
            bestTimes = bestTimesManager!.fetchEntriesForDifficulty("Advanced")
            break
        default:
            break
        }
        bestTimesTableView.reloadData()
    }

    @IBAction func ResetAllBestTimesButtonPressed(_ sender: UIBarButtonItem) {
        if let context = managedObjectContext {
            if scoresAreNotEmpty(context) {
                let alert: UIAlertController = UIAlertController.init(title: "Are you sure you want to reset all best times?",
                                                                      message: nil,
                                                                      preferredStyle: .alert)
                let dismissAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
                let continueAction = UIAlertAction.init(title: "Reset All", style: .default) { (action) in
                    self.bestTimesManager!.resetAllBestTimes()
                    self.bestTimes = self.bestTimesManager!.fetchEntriesForDifficulty(self.defaultDifficulty)
                    self.bestTimesTableView.reloadData()
                }
                alert.addAction(dismissAction)
                alert.addAction(continueAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func scoresAreNotEmpty(_ context: NSManagedObjectContext) -> Bool {
        for difficulty in pickerData {
            if !bestTimesManager!.fetchEntriesForDifficulty(difficulty).isEmpty {
                return true
            }
        }
        return false
    }
    
}
