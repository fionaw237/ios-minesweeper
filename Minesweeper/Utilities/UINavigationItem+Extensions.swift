//
//  UINavigationItem+Extensions.swift
//  Minesweeper
//
//  Created by Fiona on 24/08/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import UIKit

extension UINavigationItem {
    
    func configureBackButton(barButtonSystemItem: UIBarButtonItem.SystemItem, target: Any?, action: Selector?, colour: UIColor) {
        leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: barButtonSystemItem, target: target, action: action)
        leftBarButtonItem?.tintColor = colour
    }
}

