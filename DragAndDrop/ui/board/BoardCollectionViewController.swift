//
//  MainViewController.swift
//  DragAndDrop
//
//  Created by Dzaky on 23/11/21.
//

import UIKit
import MobileCoreServices

class BoardCollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var boards = [
        Board(title: "Todo", tasks: ["Task One", "Task Two", "Task Three", "Task Four", "Task Five"]),
        Board(title: "In Progress", tasks: ["Task OneOne", "Task TwoTwo", "Task ThreeThree", "Task FourFour", "Task FiveFive"]),
        Board(title: "Done", tasks: ["Task 1", "Task 2"])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        updateCollectionViewItem(with: view.bounds.size)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateCollectionViewItem(with: size)
    }
    
    private func setupNavBar() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.shadowColor = .clear
        navBarAppearance.shadowImage = UIImage()
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationItem.title = "Tasks Board"
        setupAddButtonItem()
    }
    
    private func updateCollectionViewItem(with size: CGSize) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        layout.itemSize = CGSize(width: 300, height: size.height * 0.85)
    }
    
    func setupAddButtonItem() {
        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBoard(_:)))
        navigationItem.rightBarButtonItem = addButtonItem
    }
    
    func removeAddButtonItem() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .red
        button.addInteraction(UIDropInteraction(delegate: self))
        let removeBarButtonItem = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = removeBarButtonItem
    }
    
    @objc func addBoard(_ sender: Any) {
        let alert = UIAlertController(title: "Add Board", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            guard let text = alert.textFields?.first?.text, !text.isEmpty else {
                return
            }
            
            self.boards.append(Board(title: text, tasks: []))
            
            let addedBoardIndexPath = IndexPath(item: self.boards.count - 1, section: 0)
            
            self.collectionView.insertItems(at: [addedBoardIndexPath])
            self.collectionView.scrollToItem(at: addedBoardIndexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension BoardCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return boards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoardCell", for: indexPath) as! BoardCollectionViewCell
        cell.setup(board: boards[indexPath.item])
        cell.parentViewController = self
        return cell
    }
    
}

extension BoardCollectionViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        if session.hasItemsConforming(toTypeIdentifiers: [kUTTypePlainText as String]) {
            session.loadObjects(ofClass: NSString.self) { items in
                guard let _ = items.first as? String else {
                    return
                }
                
                if let (dataSource, sourceIndexPath, tableView) = session.localDragSession?.localContext as? (Board, IndexPath, UITableView) {
                    tableView.beginUpdates()
                    dataSource.tasks.remove(at: sourceIndexPath.row)
                    tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
                    tableView.endUpdates()
                }
            }
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .move)
    }
    
}
