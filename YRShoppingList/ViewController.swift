//
//  ViewController.swift
//  YRShoppingList
//
//  Created by Yuan Zhou on 2020/05/01.
//  Copyright © 2020 ZhouyuanWork, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!

//    var items = [Item]()

    // for debug
    var items = [
        Item(name: "1", isChecked: false, quantity: 1),
        Item(name: "2", isChecked: false, quantity: 2),
        Item(name: "3", isChecked: true, quantity: 3),
        Item(name: "4", isChecked: false, quantity: 4),
        Item(name: "5", isChecked: false, quantity: 5),
        Item(name: "6", isChecked: false, quantity: 6),
        Item(name: "7", isChecked: true, quantity: 7),
        Item(name: "8", isChecked: false, quantity: 8),
        Item(name: "9", isChecked: false, quantity: 9),
        Item(name: "10", isChecked: false, quantity: 10),
        Item(name: "11", isChecked: true, quantity: 11),
        Item(name: "12", isChecked: false, quantity: 12),
        Item(name: "13", isChecked: false, quantity: 13),
        Item(name: "14", isChecked: false, quantity: 14),
        Item(name: "15", isChecked: true, quantity: 15),
        Item(name: "16", isChecked: false, quantity: 16),
        Item(name: "17", isChecked: false, quantity: 17),
    ]

    private let reuseIdentifier = "CustomCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = editButtonItem

        collectionView.register(UINib(nibName: "ListItemCell", bundle: nil), forCellWithReuseIdentifier: "CustomCell")
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        collectionView.allowsMultipleSelection = editing
        let indexPaths = collectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            if let cell = collectionView.cellForItem(at: indexPath) as? ListItemCell {
                cell.isInEditingMode = editing
            }
        }

        if editing == false {
            deleteButton.isEnabled = false
        }
    }

    @IBAction func deleteItem(_ sender: Any) {
        if let selectedCells = collectionView.indexPathsForSelectedItems {
            let selectedItems = selectedCells.map { $0.item }.sorted().reversed()
            for selectedItem in selectedItems {
                items.remove(at: selectedItem)
            }
            collectionView.deleteItems(at: selectedCells)
            deleteButton.isEnabled = false
        }
    }

}

extension ViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard items.count > 0 else { return 1 }
        return items.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
          .dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        if let cell = cell as? ListItemCell {
            // Configure the cell

            var original: Item
            let index = indexPath.row
            if index < items.count {
                original = items[indexPath.row]
            } else {
                original = Item(name: "", isChecked: false, quantity: 1)
            }

            cell.configure(item: original)
            cell.didSaveItemHandler = { [weak self] item in
                guard let self = self, item.name.isEmpty == false else { return }
                let firstIndex = self.items.firstIndex { $0 == original }
                if let index  = firstIndex, index >= 0 {
                    self.items[index] = item
                } else {
                    self.items.append(item)
                }
                self.collectionView.reloadData()
            }
            cell.showNameInputAlertHandler = { [weak self] in
                guard let self = self else { return }
                self.showNeedToInputNameAlert()
            }

            cell.isInEditingMode = isEditing
        }

        return cell
    }
}

extension ViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isEditing {
            deleteButton.isEnabled = false
        } else {
            deleteButton.isEnabled = true
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let selectedItems = collectionView.indexPathsForSelectedItems, selectedItems.count == 0 {
            deleteButton.isEnabled = false
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width,
                      height: 60.0)
    }
}

extension ViewController: UICollectionViewDragDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        let item = items[indexPath.row]
        guard item.name.isEmpty == false else { return [] }
        let itemObject = NSItemProvider(object: item.name as NSString)
        let dragItem = UIDragItem(itemProvider: itemObject)
        return [dragItem]
    }
}

extension ViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }

        coordinator.items.forEach { dropItem in
            guard let sourceIndexPath = dropItem.sourceIndexPath else { return }
            collectionView.performBatchUpdates({
                let item = items[sourceIndexPath.row]
                items.remove(at: sourceIndexPath.row)
                items.insert(item, at: destinationIndexPath.row)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            }, completion: { _ in
                coordinator.drop(dropItem.dragItem,
                                 toItemAt: destinationIndexPath)
            })
        }
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal( operation: .move,
                                             intent: .insertAtDestinationIndexPath)
    }

    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return true
    }


}

extension ViewController {

    private func showNeedToInputNameAlert() {
        let alert = UIAlertController(title:"品名がありません", message: "先に名前を入力ください", preferredStyle: UIAlertController.Style.alert)
        let cancel = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) in
        })
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    @objc private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            collectionView.contentInset = .zero
        } else {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        collectionView.scrollIndicatorInsets = collectionView.contentInset
    }
}
