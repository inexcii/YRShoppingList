//
//  Item.swift
//  YRShoppingList
//
//  Created by Yuan Zhou on 2020/05/04.
//  Copyright © 2020 ZhouyuanWork, Inc. All rights reserved.
//

import Foundation

struct Item: Equatable, Hashable, Codable {

    var name: String
    var isChecked: Bool
    var quantity: Int

    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.name == rhs.name
            && lhs.isChecked == rhs.isChecked
            && lhs.quantity == rhs.quantity
    }

    
}
