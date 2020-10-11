//
//  CategoryRealm.swift
//  Todoey
//
//  Created by Kunal Tyagi on 27/09/20.
//  Copyright © 2020 Kunal Tyagi. All rights reserved.
//

import Foundation
import RealmSwift

class CategoryRealm: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String?
    let items = List<ItemRealm>()
}
