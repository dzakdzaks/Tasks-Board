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
        setupCollectionView()
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
    
    private func setupCollectionView() {
        let gesture = UILongPressGestureRecognizer(target: self,
                                                   action: #selector(handlerlongPressGesture(_:)))
        collectionView.addGestureRecognizer(gesture)
    }
    
    @objc func handlerlongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        guard let collectionView = collectionView else {
            return
        }
        
        switch gesture.state {
        case .began:
            guard let targetIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                return
            }
            collectionView.beginInteractiveMovementForItem(at: targetIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }

    
}

extension BoardCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return boards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BoardCell", for: indexPath) as! BoardCollectionViewCell
        cell.setup(board: boards[indexPath.row], index: indexPath.row)
        cell.delegate = self
        cell.parentViewController = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let board = boards.remove(at: sourceIndexPath.row)
        boards.insert(board, at: destinationIndexPath.row)
        self.collectionView.scrollToItem(at: destinationIndexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
    }
    
}

extension BoardCollectionViewController: BoardCollectionViewCellDelegate {
    
    func didDeleteBoard(board: Board, index: Int) {
        self.boards.remove(at: index)
        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
        
        let range = NSMakeRange(0, self.collectionView.numberOfSections)
        let sections = NSIndexSet(indexesIn: range)
        self.collectionView.reloadSections(sections as IndexSet)
    }
    
}
