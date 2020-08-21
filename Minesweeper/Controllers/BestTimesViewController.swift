//
//  BestTimesViewController.swift
//  Minesweeper
//
//  Created by Fiona Wilson on 20/08/2019.
//  Copyright © 2019 Fiona Wilson. All rights reserved.
//

import UIKit
import CoreData

class BestTimesViewController: UIViewController {
    
    @IBOutlet weak var bestTimesTableView: UITableView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var bestTimesManager = BestTimesManager(
        context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    )
    
    var pickerData = [
        GameDifficulty.Beginner.rawValue,
        GameDifficulty.Intermediate.rawValue,
        GameDifficulty.Advanced.rawValue
    ]
    var bestTimes: [BestTimeEntry] = []
    var defaultDifficulty = GameDifficulty.Beginner.rawValue
    
    //MARK:- Lifecycle methods
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        bestTimes = bestTimesManager.fetchEntriesForDifficulty(defaultDifficulty)
        setSelectedDifficultyInPickerView()
    }
    
    //MARK:- Navigation
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion:nil)
    }


    //MARK:- Methods handling the resetting of high scores

    @IBAction func ResetAllBestTimesButtonPressed(_ sender: UIBarButtonItem) {
        
        if scoresAreNotEmpty(context) {
            
            let alert: UIAlertController = UIAlertController.init(title: "Are you sure you want to reset all best times?",
                                                                  message: nil,
                                                                  preferredStyle: .alert)
            
            let dismissAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
    
            let continueAction = UIAlertAction.init(title: "Reset All", style: .default) { (action) in
                self.bestTimesManager.resetAllBestTimes()
                self.bestTimes = self.bestTimesManager.fetchEntriesForDifficulty(self.defaultDifficulty)
                self.bestTimesTableView.reloadData()
            }
            
            alert.addAction(dismissAction)
            alert.addAction(continueAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func scoresAreNotEmpty(_ context: NSManagedObjectContext) -> Bool {
        for difficulty in pickerData {
            if !bestTimesManager.fetchEntriesForDifficulty(difficulty).isEmpty {
                return true
            }
        }
        return false
    }
    
}

// MARK:- Picker view methods

extension BestTimesViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
            bestTimes = bestTimesManager.fetchEntriesForDifficulty(GameDifficulty.Beginner.rawValue)
        case 1:
            bestTimes = bestTimesManager.fetchEntriesForDifficulty(GameDifficulty.Intermediate.rawValue)
        case 2:
            bestTimes = bestTimesManager.fetchEntriesForDifficulty(GameDifficulty.Advanced.rawValue)
        default:
            break
        }
        
        bestTimesTableView.reloadData()
    }
    
    func setSelectedDifficultyInPickerView() {
        guard let rowToSelect = pickerData.firstIndex(of: defaultDifficulty) else {
            fatalError("Default difficulty \(defaultDifficulty) does not appear in the picker view's data")
        }
        pickerView.selectRow(rowToSelect, inComponent: 0, animated: true)
    }
}

// MARK:- Table view delegate methods

extension BestTimesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bestTimes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BestTimesTableViewCell.self), for: indexPath) as! BestTimesTableViewCell
        cell.configure(row:indexPath.row, timeEntry:bestTimes[indexPath.row])
        return cell
    }
}
