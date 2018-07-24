//
//  ExampleViewController.swift
//  TSQBiometricAuth
//
//  Created by Kévin Cardoso de Sá on 06/25/2018.
//  Copyright (c) 2018 Kévin Cardoso de Sá. All rights reserved.
//

import UIKit
import TSQBiometricAuth

class ExampleViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func showAuthenticationModal() {
        
        // Setting up the font
        guard let font = UIFont(name: "Shrikhand", size: 14.0) else {
            return
        }
        
        // Setting up left button
        let cancelButtonConfig = TSQButtonConfiguration(cornerRadius: 5.0,
                                                    borderColor: UIColor(hexString: "7ebc0a"),
                                                    borderWidth: 1.0,
                                                    backgroundColor: UIColor.white,
                                                    height: 80.0,
                                                    text: "Cancel",
                                                    textColor: UIColor.black,
                                                    font: font)
        
        // Setting up right button
        let authenticateButtonConfig = TSQButtonConfiguration(cornerRadius: 5.0,
                                                    borderColor: UIColor(hexString: "7ebc0a"),
                                                    borderWidth: 1.0,
                                                    backgroundColor: UIColor.white,
                                                    height: 80.0,
                                                    text: "Authenticate",
                                                    textColor: UIColor.black,
                                                    font: font)
        
        // Setting up logo
        guard let logoImage = UIImage(named: "logo") else {
            return
        }
        let logoImageConfig = TSQImageConfiguration(height: 80,
                                                    width: 220,
                                                    contentMode: .scaleToFill)
        
        guard let viewController = TSQBioAuth
            .instantiateTSQBioAuthViewController(displayMessage: "Message shown when asking users for their fingerprint",
                                                 leftButtonConfiguration: cancelButtonConfig,
                                                 rightButtonConfiguration: authenticateButtonConfig,
                                                 logoImage: logoImage,
                                                 logoImageConfiguration: logoImageConfig,
                                                 backgroundColor: UIColor(hexString: "d9d9d9")) else {
            return
        }
        viewController.delegate = self
        
        self.present(viewController, animated: true, completion: nil)
    }
}

extension ExampleViewController: TSQBioAuthenticationDelegate {
    func authenticationSucceeded() {
        print("succeded")
    }
    func authenticationDisabledByUserChoice() {
        print("disabled by user choice")
    }
}

