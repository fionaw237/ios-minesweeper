//
//  UIAlertController+Extensions.swift
//  Minesweeper
//
//  Created by Fiona on 22/08/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import UIKit

extension UIAlertController {
 
    static func alert(title: String, message: String, actions: [UIAlertAction], completion: (UIAlertController) -> Void) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        actions.forEach { alertController.addAction($0) }
        completion(alertController)
    }
}
