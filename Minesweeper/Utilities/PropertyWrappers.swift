//
//  PropertyWrappers.swift
//  Minesweeper
//
//  Created by Fiona on 26/08/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import Foundation

@propertyWrapper
struct DefaultSynced<Value> {
    let key: String
    let defaultValue: Value
    var wrappedValue: Value {
        get {
            UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
