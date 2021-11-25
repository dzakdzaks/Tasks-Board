//
//  TaskCell.swift
//  DragAndDrop
//
//  Created by Dzaky on 24/11/21.
//

import UIKit

class TaskCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
       
    func setup(task: String) {
        self.titleLabel.text = task
    }
    
}
