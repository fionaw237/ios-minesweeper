//
//  BestTimesViewController.swift
//  Minesweeper
//
//  Created by Fiona Wilson on 20/08/2019.
//  Copyright © 2019 Fiona Wilson. All rights reserved.
//

import UIKit

class BestTimesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var bestTimesTableView: UITableView!
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion:nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BestTimesTableViewCell.self), for: indexPath) as! BestTimesTableViewCell
        return cell
    }

}
