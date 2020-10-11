//
//  Item_Realm.swift
//  Todoey
//
//  Created by Kunal Tyagi on 27/09/20.
//  Copyright © 2020 Kunal Tyagi. All rights reserved.
//

import Foundation
import RealmSwift

class ItemRealm: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: CategoryRealm.self, property: "items")
}
