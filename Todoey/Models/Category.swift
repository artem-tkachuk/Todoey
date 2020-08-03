//
//  Category.swift
//  Todoey
//
//  Created by Artem Tkachuk on 8/3/20.
//  Copyright © 2020 Artem Tkachuk. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
