//
//  ExampleViewController.swift
//  TSQBiometricAuth
//
//  Created by Kévin Cardoso de Sá on 06/25/2018.
//  Copyright (c) 2018 Kévin Cardoso de Sá. All rights reserved.
//

import RxSwift
import UIKit
import TSQBiometricAuth
import LocalAuthentication

class ExampleViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func showAuthenticationModal() {
        let tsqBioAuth = TSQBioAuth(onlyBiometrics: false)
        
        // Setting up the font
        guard let font = UIFont(name: "Helvetica", size: 13) else {
            return
        }
        
        // Setting up left button
        let cancelButtonConfig = TSQButtonConfiguration(cornerRadius: 5.0,
                                                    borderColor: UIColor(hexString: "d9d9d9"),
                                                    borderWidth: 1.0,
                                                    backgroundColor: UIColor.white,
                                                    height: 40.0,
                                                    text: "Cancel",
                                                    textColor: UIColor.black,
                                                    font: font)
        
        // Setting up right button
        let authenticateButtonConfig = TSQButtonConfiguration(cornerRadius: 5.0,
                                                    borderColor: .black,
                                                    borderWidth: 1.0,
                                                    backgroundColor: UIColor.white,
                                                    height: 40.0,
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
        
        guard let viewController = tsqBioAuth
            .instantiateTSQBioAuthViewController(displayMessage: "Message shown when asking users for their fingerprint",
                                                 leftButtonConfiguration: cancelButtonConfig,
                                                 rightButtonConfiguration: authenticateButtonConfig,
                                                 logoImage: logoImage,
                                                 logoImageConfiguration: logoImageConfig,
                                                 backgroundColor: UIColor(hexString: "d9d9d9")) else {
            return
        }
        // Conform to the protocol
        viewController.delegate = self
        // OR
        // Use the Reactive solution and subscribe!!
        viewController.authenticationState.subscribe(onNext: { (state) in
            switch state {
            case .success:
                print("Authentication Succeeded")
            case .error(code: let errorCode):
                switch errorCode {
                case LAError.Code.userCancel.rawValue:
                    print("User cancelled")
                default:
                    print("Authentication Failed with error: \(errorCode)")
                }
            case .disabledByUserChoice:
                print("Authentication Disabled by User Choice")
            }
        }).disposed(by: self.disposeBag)
        
        self.present(viewController, animated: true, completion: nil)
    }
}

// Implement the protocol
extension ExampleViewController: TSQBioAuthenticationDelegate {
    func authenticationFailed(withErrorCode errorCode: Int) {
        switch errorCode {
        case LAError.Code.userCancel.rawValue:
            print("User cancelled")
        default:
            print("Authentication Failed with error: \(errorCode)")
        }
    }
    
    func authenticationSucceeded() {
        print("Authentication Succeeded")
    }
    
    func authenticationDisabledByUserChoice() {
        print("Authentication Disabled by User Choice")
    }
}

