//
//  Items.swift
//  Todoey
//
//  Created by Kunal Tyagi on 19/01/20.
//  Copyright © 2020 Kunal Tyagi. All rights reserved.
//

import Foundation

class Items: NSObject, NSCoding {
    var itemName: String = ""
    var isSelected: Bool = false
    
    init(itemName: String, isSelected: Bool) {
        self.itemName = itemName
        self.isSelected = isSelected
    }
    
    required convenience init?(coder: NSCoder) {
        guard let itemName = coder.decodeObject(forKey: "itemName") as? String else { return nil }
        let isSelected = coder.decodeBool(forKey: "isSelected")
        self.init(itemName: itemName, isSelected: isSelected)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(itemName, forKey: "itemName")
        coder.encode(isSelected, forKey: "isSelected")
    }
}
