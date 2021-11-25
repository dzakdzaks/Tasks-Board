//
//  Board.swift
//  DragAndDrop
//
//  Created by Dzaky on 23/11/21.
//

import Foundation
import UIKit

class Board: Codable {
    
    var title: String
    var tasks: [String]
    
    init(title: String, tasks: [String]) {
        self.title = title
        self.tasks = tasks
    }
    
}
