//
//  BestTimesViewController.swift
//  Minesweeper
//
//  Created by Fiona Wilson on 20/08/2019.
//  Copyright © 2019 Fiona Wilson. All rights reserved.
//

import UIKit

class BestTimesViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIButton!
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion:nil)
    }
    
}
