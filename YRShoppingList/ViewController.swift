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

    var items = [Item]()

    private let reuseIdentifier = "CustomCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "ListItemCell", bundle: nil), forCellWithReuseIdentifier: "CustomCell")

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
        }

        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
}

extension ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width,
                      height: 60.0)
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
}
