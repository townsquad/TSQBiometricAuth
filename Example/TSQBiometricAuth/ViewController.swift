//
//  ViewController.swift
//  TSQBiometricAuth
//
//  Created by Kévin Cardoso de Sá on 06/25/2018.
//  Copyright (c) 2018 Kévin Cardoso de Sá. All rights reserved.
//

import UIKit
import TSQBiometricAuth

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onButtonPressed() {
        let viewModel = TSQBioAuthViewModel(reason: "this is the reason")
        let viewController = TSQBioAuthViewController.create(viewModel: viewModel)
        
        self.present(viewController, animated: true, completion: nil)
    }
}

