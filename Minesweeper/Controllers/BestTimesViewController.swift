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
    @IBOutlet weak var difficultySelector: UISegmentedControl!
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var bestTimesManager = BestTimesManager(
        context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    )

    var bestTimes: [BestTimeEntry] = []
    var defaultDifficulty = GameDifficulty.Beginner.rawValue
    
    //MARK:- Lifecycle methods
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        difficultySelector.selectedSegmentIndex = GameDifficulty.selectedIndexForDifficulty(defaultDifficulty)
        bestTimes = bestTimesManager.fetchEntriesForDifficulty(defaultDifficulty)
    }
    
    //MARK:- Navigation
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion:nil)
    }

    @IBAction func difficultySelected(_ sender: UISegmentedControl) {
        bestTimes = bestTimesManager.fetchEntriesForDifficulty(sender.titleForSegment(at: sender.selectedSegmentIndex)!)
        bestTimesTableView.reloadData()
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
        for difficulty in GameDifficulty.allCases {
            if !bestTimesManager.fetchEntriesForDifficulty(difficulty.rawValue).isEmpty {
                return true
            }
        }
        return false
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
}
