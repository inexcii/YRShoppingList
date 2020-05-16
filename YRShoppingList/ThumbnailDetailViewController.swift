//
//  ThumbnailDetailViewController.swift
//  YRShoppingList
//
//  Created by Yuan Zhou on 2020/05/15.
//  Copyright © 2020 ZhouyuanWork, Inc. All rights reserved.
//

import UIKit

class ThumbnailDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    var imageData: Data? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        if let data = imageData, let image = UIImage(data: data) {
            imageView.image = image
        }
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
