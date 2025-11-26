//
//  Item.swift
//  Breakpoint
//
//  Created by Luís Cruz on 26/11/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
