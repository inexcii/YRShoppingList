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

    enum CheckState {
        case blank, checked
    }
    private var checkedState: CheckState = .blank {
        didSet {
            textField.isEnabled = checkedState == .blank
        }
    }

    private var quantity: Int = 1

    override func awakeFromNib() {
        super.awakeFromNib()


    }

    override func prepareForReuse() {
        super.prepareForReuse()

        checkedState = .blank
        quantity = 1
        checkButton.setBackgroundImage(UIImage(systemName: "square"), for: .normal)
        quantityLabel.text = "\(quantity)"
    }

    @IBAction func checkButtonTapped(_ sender: Any) {
        if textField.canResignFirstResponder {
            textField.resignFirstResponder()
        }

        if checkedState == .blank {
            checkButton.setBackgroundImage(UIImage(systemName: "checkmark.square"), for: .normal)
            checkedState = .checked
            textField.attributedText = textField.text?.strikeThroughStyle()
        } else {
            checkButton.setBackgroundImage(UIImage(systemName: "square"), for: .normal)
            checkedState = .blank
            textField.text = textField.text
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
        textField.resignFirstResponder()
        return true
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
