//
//  ListItemCell.swift
//  YRShoppingList
//
//  Created by Yuan Zhou on 2020/05/03.
//  Copyright © 2020 ZhouyuanWork, Inc. All rights reserved.
//

import UIKit

protocol ListItemCellDelegate: class {
    func didTapCheckButton()
}

class ListItemCell: UICollectionViewCell {

    @IBOutlet private weak var checkButton: UIButton!
    @IBOutlet private weak var quantityLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!

    weak var delegate: ListItemCellDelegate?
    var didSaveItemHandler: ((Item) -> Void)?

    private var item: Item? {
        didSet {
            guard let item = item else {
                print("no item to save")
                return
            }
            didSaveItemHandler?(item)
        }
    }

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
        isChecked = !isChecked

        if textField.canResignFirstResponder {
            resignKeyboardAndSaveName()
        }

        self.delegate?.didTapCheckButton()
    }

    @IBAction func plusButtonTapped(_ sender: Any) {
        quantity += 1
        quantityLabel.text = "\(quantity)"
    }

    @IBAction func minusButtonTapped(_ sender: Any) {
        guard quantity > 1 else { return }
        quantity -= 1
        quantityLabel.text = "\(quantity)"
    }

}

extension ListItemCell: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignKeyboardAndSaveName()
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
