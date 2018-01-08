//
//  ViewController.swift
//  ios-twitter-transition
//
//  Created by OkuderaYuki on 2018/01/09.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Actions
    
    @IBAction func didTapSend(_ sender: UIButton) {
        let modalVC = ModalViewController.make()
        present(modalVC, animated: true, completion: nil)
    }
}
