//
//  ListItemCell.swift
//  YRShoppingList
//
//  Created by Yuan Zhou on 2020/05/03.
//  Copyright © 2020 ZhouyuanWork, Inc. All rights reserved.
//

import UIKit

class ListItemCell: UICollectionViewCell {

    @IBOutlet private weak var checkButton: UIButton!
    @IBOutlet private weak var quantityLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!

    var didSaveItemHandler: ((Item) -> Void)?
    var showNameInputAlertHandler: (() -> Void)?

    private var item: Item!

    private var isChecked: Bool = false {
        didSet {
            textField.isEnabled = !isChecked

            if isChecked {
                checkButton.setBackgroundImage(UIImage(systemName: "checkmark.square"), for: .normal)
                textField.attributedText = textField.text?.strikeThroughStyle()
            } else {
                checkButton.setBackgroundImage(UIImage(systemName: "square"), for: .normal)
                textField.text = textField.text
            }

            item?.isChecked = isChecked
        }
    }

    private var quantity: Int = 0 {
        didSet {
            quantityLabel.text = "\(quantity)"
            item?.quantity = quantity
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()


    }

    override func prepareForReuse() {
        super.prepareForReuse()

        textField.text = ""
        quantity = 1
        isChecked = false
    }

    func configure(item: Item) {
        textField.text = item.name
        quantity = item.quantity
        isChecked = item.isChecked
        self.item = item
    }

    @IBAction func checkButtonTapped(_ sender: Any) {
        guard self.item.name.isEmpty == false else {
            showNameInputAlertHandler?()
            return
        }

        isChecked = !isChecked

        if textField.canResignFirstResponder {
            resignKeyboardAndSaveName()
        }

        didSaveItemHandler?(self.item)
    }

    @IBAction func plusButtonTapped(_ sender: Any) {
        guard self.item.name.isEmpty == false else {
            showNameInputAlertHandler?()
            return
        }

        quantity += 1
        quantityLabel.text = "\(quantity)"

        didSaveItemHandler?(self.item)
    }

    @IBAction func minusButtonTapped(_ sender: Any) {
        guard self.item.name.isEmpty == false else {
            showNameInputAlertHandler?()
            return
        }
        guard quantity > 1 else { return }

        quantity -= 1
        quantityLabel.text = "\(quantity)"

        didSaveItemHandler?(self.item)
    }

}

extension ListItemCell: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignKeyboardAndSaveName()
        didSaveItemHandler?(self.item)
        return true
    }
}

extension ListItemCell {

    private func resignKeyboardAndSaveName() {
        textField.resignFirstResponder()
        guard let name = textField.text else {
            print("not save name with nil in the textField")
            return
        }
        item?.name = name
    }
}

extension String {
    func strikeThroughStyle() -> NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.addAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.gray,
            NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.strikethroughColor: UIColor.gray
        ], range: NSMakeRange(0,attributeString.length))
        return attributeString
    }
}


