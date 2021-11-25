//
//  TaskCell.swift
//  DragAndDrop
//
//  Created by Dzaky on 23/11/21.
//

import UIKit
import MobileCoreServices
import PanModal

protocol BoardCollectionViewCellDelegate: AnyObject {
    func didDeleteBoard(board: Board, index: Int)
}


class BoardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: BoardCollectionViewCellDelegate?
    weak var parentViewController: BoardCollectionViewController?
    var board: Board!
    var index: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 10
        
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
        tableView.tableFooterView = UIView()
    }
    
    func setup(board: Board, index: Int) {
        self.board = board
        self.index = index
        tableView.reloadData()
    }
    
    
    @IBAction func addTaskClicked(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Add Task", message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            guard let taskText = alertController.textFields?.first?.text, !taskText.isEmpty else {
                return
            }
            
            guard let data = self.board else {
                return
            }
            
            data.tasks.append(taskText)
            let addedTaskIndexPath = IndexPath(item: data.tasks.count - 1, section: 0)
            
            self.tableView.insertRows(at: [addedTaskIndexPath], with: .left)
            self.tableView.scrollToRow(at: addedTaskIndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
            
        }))
        parentViewController?.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func deleteBoardClicked(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Are you sure delete \(self.board?.title ?? "this") board?", message: "Deleted board can't be returned", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Delete", style: .default, handler: { _ in
            self.delegate?.didDeleteBoard(board: self.board, index: self.index)
        }))
        parentViewController?.present(alertController, animated: true, completion: nil)
    }
    
}

extension BoardCollectionViewCell: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return board?.tasks.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: contentView.bounds.size.width, y: contentView.bounds.size.height, width: contentView.bounds.size.width, height: 25))
        headerView.backgroundColor = .lightGray
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: headerView.bounds.size.width, height: headerView.bounds.size.height))
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.text = board?.title ?? ""
        headerView.addSubview(label)
        
        return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        let task = board?.tasks[indexPath.row] ?? "-"
        cell.setup(task: task)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = board?.tasks[indexPath.row] ?? "-"
        let taskController = TaskViewController()
        taskController.delegate = self
        taskController.setup(task: task, index: indexPath.row)
        parentViewController?.presentPanModal(taskController)
    }
    
}

extension BoardCollectionViewCell: TaskDelegate {
    
    func didEditTask(task: String, index: Int) {
        guard let data = self.board else {
            return
        }
        
        data.tasks[index] = task
        let editedIndexPath = IndexPath(item: index, section: 0)
                
        self.tableView.reloadRows(at: [editedIndexPath], with: .automatic)
    }
    
    func didDeleteTask(task: String, index: Int) {
        self.tableView.beginUpdates()
        self.board?.tasks.remove(at: index)
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .right)
        self.tableView.endUpdates()
        
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesIn: range)
        self.tableView.reloadSections(sections as IndexSet, with: .automatic)
    }
    
}

extension BoardCollectionViewCell: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let board = board, let stringData = board.tasks[indexPath.row].data(using: .utf8) else {
            return []
        }
        
        let itemProvider = NSItemProvider(item: stringData as NSData, typeIdentifier: kUTTypePlainText as String)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        session.localContext = (board, indexPath, tableView)
        
        return [dragItem]
    }
}

extension BoardCollectionViewCell: UITableViewDropDelegate {
    
    
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        if coordinator.session.hasItemsConforming(toTypeIdentifiers: [kUTTypePlainText as String]) {
            coordinator.session.loadObjects(ofClass: NSString.self, completion: { items in
                guard let stringData = items.first as? String else {
                    return
                }
                
                switch (coordinator.items.first?.sourceIndexPath, coordinator.destinationIndexPath) {
                case (.some(let sourceIndexPath), .some(let destinationIndexPath)):
                    // Same Table View
                    let updateIndexPath: [IndexPath]
                    if sourceIndexPath.row < destinationIndexPath.row {
                        updateIndexPath = (sourceIndexPath.row...destinationIndexPath.row).map {
                            IndexPath(row: $0, section: 0)
                        }
                    } else if sourceIndexPath.row > destinationIndexPath.row {
                        updateIndexPath = (destinationIndexPath.row...sourceIndexPath.row).map {
                            IndexPath(row: $0, section: 0)
                        }
                    } else {
                        updateIndexPath = []
                    }
                    self.tableView.beginUpdates()
                    self.board?.tasks.remove(at: sourceIndexPath.row)
                    self.board?.tasks.insert(stringData, at: destinationIndexPath.row)
                    self.tableView.reloadRows(at: updateIndexPath, with: .automatic)
                    self.tableView.endUpdates()
                    break
                case (nil, .some(let destinationIndexPath)):
                    // Move data from a table to another table
                    self.removeSourceTableData(localContext: coordinator.session.localDragSession?.localContext)
                    self.tableView.beginUpdates()
                    self.board?.tasks.insert(stringData, at: destinationIndexPath.row)
                    self.tableView.insertRows(at: [destinationIndexPath], with: .automatic)
                    self.tableView.endUpdates()
                    break
                case (nil, nil):
                    // Insert data from a table to another table
                    self.removeSourceTableData(localContext: coordinator.session.localDragSession?.localContext)
                    self.tableView.beginUpdates()
                    self.board?.tasks.append(stringData)
                    self.tableView.insertRows(at: [IndexPath(row: self.board!.tasks.count - 1, section: 0)], with: .automatic)
                    self.tableView.endUpdates()
                    break
                default:
                    break
                }
            })
        }
    }
    
    func removeSourceTableData(localContext: Any?) {
        if let (dataSource, sourceIndexPath, tableView) = localContext as? (Board, IndexPath, UITableView) {
            tableView.beginUpdates()
            dataSource.tasks.remove(at: sourceIndexPath.row)
            tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
}
