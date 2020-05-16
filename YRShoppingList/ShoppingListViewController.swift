//
//  ShoppingListViewController.swift
//  YRShoppingList
//
//  Created by Yuan Zhou on 2020/05/07.
//  Copyright © 2020 ZhouyuanWork, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class ShoppingListViewController: UITableViewController {

    let shareService = ListShareService()
    var items = [Item]() {
        didSet {
            saveData()
        }
    }

    private var selectedThumbnailCellIndex: IndexPath = IndexPath()

    override func viewDidLoad() {
        super.viewDidLoad()

        shareService.delegate = self

        self.navigationItem.leftBarButtonItem = self.editButtonItem
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "Cell")

        items = getData()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        let indexPaths = tableView.indexPathsForVisibleRows
        guard let paths = indexPaths else { return }
        for path in paths {
            if let cell = tableView.cellForRow(at: path) as? ItemCell {
                cell.isInEditingMode = editing
            }
        }
    }

    @IBAction func shareList(_ sender: Any) {
        shareService.searchForPeer()
    }
}

// Datasource
extension ShoppingListViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard items.count > 0 else { return 1 }
        return items.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ItemCell

        var item: Item
        let index = indexPath.row
        if index < items.count {
            item = items[indexPath.row]
        } else {
            item = Item(name: "", isChecked: false, quantity: 1)
        }

        cell.configure(item: item)
        cell.didSaveItemHandler = { [weak self] savedItem in
            guard let self = self, !savedItem.name.isEmpty else { return }
            let firstIndex = self.items.firstIndex { $0 == item }
            if let index = firstIndex, index >= 0 {
                // edit item
                self.items[index] = savedItem
                tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                // add item
                self.items.append(savedItem)
                tableView.reloadData()
            }
        }
        cell.showNameInputAlertHandler = { [weak self] in
            guard let self = self else { return }
            self.showNeedToInputNameAlert()
        }
        cell.didTapThumbnail = { hasImage in
            if !hasImage {
                let src = UIImagePickerController.SourceType.photoLibrary
                guard UIImagePickerController.isSourceTypeAvailable(src)
                    else { return }
                guard let arr = UIImagePickerController.availableMediaTypes(for:src)
                    else { return }
                let picker = UIImagePickerController()
                picker.sourceType = src
                picker.mediaTypes = arr
                picker.delegate = self
                picker.videoExportPreset = AVAssetExportPresetLowQuality
                self.present(picker, animated: true, completion: nil)
            } else {
                let menu = UIAlertController(title: nil, message: "実行項目", preferredStyle: .actionSheet)
                let check = UIAlertAction(title: "確認", style: .default) { action in
                    guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ThumbnailDetailViewController") as? ThumbnailDetailViewController,
                        let index = self.items.firstIndex(of: cell.item),
                        let imageData = self.items[index].thumbnailData else { return }
                    vc.imageData = imageData
                    self.present(vc, animated: true, completion: nil)
                }
                let delete = UIAlertAction(title: "削除", style: .default) { [weak self] action in
                    guard let self = self, let index = self.items.firstIndex(of: cell.item) else { return }
                    self.items.removeAll { item -> Bool in
                        item == cell.item
                    }
                    var newItem = cell.item
                    newItem?.thumbnailData = nil
                    guard let item = newItem else { return }
                    self.items.insert(item, at: index)
                    cell.thumbnail.setBackgroundImage(nil, for: .normal)
                }
                let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
                menu.addAction(check)
                menu.addAction(delete)
                menu.addAction(cancel)
                self.present(menu, animated: true, completion: nil)
            }

            self.selectedThumbnailCellIndex = indexPath
        }

        cell.isInEditingMode = isEditing
        
        return cell
    }
}

// Delegate
extension ShoppingListViewController {

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        print("commit row at: \(indexPath.row)")
        switch editingStyle {
        case .delete:
            tableView.performBatchUpdates({
                items.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }) { finished in
                print("finished printing")
            }
        default:
            print("not .delete style")
        }
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // change data order
        let item = items.remove(at: sourceIndexPath.row)
        items.insert(item, at: destinationIndexPath.row)
    }
}

extension ShoppingListViewController: ListShareServiceDelegate {

    func didConnectWithPeerDeviceToSend(names: [String]) {
        DispatchQueue.main.async {
            self.showSharePeerConnectedAlert(peers: names, isToSend: true) {
                guard let data = try? PropertyListEncoder().encode(self.items) else { return }
                self.shareService.send(list: data)
            }
        }
    }

    func didConnectWithPeerDevice(names: [String]) {
        DispatchQueue.main.async {
            self.showSharePeerConnectedAlert(peers: names)
        }
    }

    func didReceiveData(_ data: Data) {
        guard let items = try? PropertyListDecoder().decode([Item].self, from: data) else { return }
        print("received items: \(items)")
        DispatchQueue.main.async {
            self.showReceivedListAlert { [weak self] in
                guard let self = self else { return }
                self.items = items

                self.tableView.reloadData()
            }
        }
    }
}

extension ShoppingListViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage,
            let cell = tableView.cellForRow(at: self.selectedThumbnailCellIndex) as? ItemCell else {
            return
        }

        // replace item data in item list
        let index = self.selectedThumbnailCellIndex.row
        let item = items[index]
        let newItem = Item(name: item.name,
                           isChecked: item.isChecked,
                           quantity: item.quantity,
                           thumbnailData: image.pngData())
        items.remove(at: index)
        items.insert(newItem, at: index)

        self.dismiss(animated:true) {
        // do something with the chosen item here
            cell.thumbnail.setBackgroundImage(image, for: .normal)
        }
    }
}

extension ShoppingListViewController: UINavigationControllerDelegate {}

extension ShoppingListViewController {

    private func showNeedToInputNameAlert() {
        let alert = UIAlertController(title:"品名がありません", message: "先に名前を入力ください", preferredStyle: UIAlertController.Style.alert)
        let cancel = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) in
        })
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    private func showSharePeerConnectedAlert(peers names: [String], isToSend: Bool = false, okHandler: (() -> Void)? = nil) {
        let namesText = names.reduce("", { result, string -> String in
            return result + "\n" + string
        })
        let title = isToSend ? "相手が見つかりました。リストを共有しますか？": "相手が見つかりました。"
        let alert = UIAlertController(title: title, message: namesText, preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { action in
            print("OK")
            okHandler?()
        }
        let cancelButtonTitle = isToSend ? "Cancel": "OK"
        let cancel = UIAlertAction(title: cancelButtonTitle, style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) in
            print("Cancel")
        })
        if isToSend {
            alert.addAction(ok)
        }
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    private func showReceivedListAlert(okHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title:"リストが共有されました", message: "受け取りますか", preferredStyle: UIAlertController.Style.alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) in
        })
        let ok = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { action in
            print("OK")
            okHandler?()
        }
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }

    private func showThumbnailActionSheet() {

    }
}

extension ShoppingListViewController {

    private func saveData() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(items), forKey: "UserDefaults_items")
        UserDefaults.standard.synchronize()
    }
    private func getData() -> [Item] {
        guard let decoded = UserDefaults.standard.object(forKey: "UserDefaults_items") as? Data,
            let items = try? PropertyListDecoder().decode([Item].self, from: decoded)
            else { return [Item]() }
        return items
    }
}
