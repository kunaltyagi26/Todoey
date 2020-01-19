//
//  Item.swift
//  Todoey
//
//  Created by Kunal Tyagi on 19/01/20.
//  Copyright © 2020 Kunal Tyagi. All rights reserved.
//

import Foundation

class Item: Codable {
    var itemName: String = ""
    var isSelected: Bool = false
    
    init(itemName: String, isSelected: Bool) {
        self.itemName = itemName
        self.isSelected = isSelected
    }
}
