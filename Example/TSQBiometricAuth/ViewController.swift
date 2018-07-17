//
//  ViewController.swift
//  TSQBiometricAuth
//
//  Created by Kévin Cardoso de Sá on 06/25/2018.
//  Copyright (c) 2018 Kévin Cardoso de Sá. All rights reserved.
//

import UIKit
import TSQBiometricAuth

public extension UIColor {
    convenience init(hexString: String) {
        let alpha = 1.0
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(255 * alpha) / 255)
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onButtonPressed() {
        guard let font = UIFont(name: "Shrikhand", size: 14.0) else {
            return
        }
        let firstButtonConfig = ButtonConfiguration(cornerRadius: 5.0,
                                                    borderColor: UIColor(hexString: "7ebc0a"),
                                                    borderWidth: 1.0,
                                                    backgroundColor: UIColor.white,
                                                    height: 80.0,
                                                    text: "Cancelar",
                                                    textColor: UIColor.black,
                                                    font: font)
        let secondButtonConfig = ButtonConfiguration(cornerRadius: 5.0,
                                                    borderColor: UIColor(hexString: "7ebc0a"),
                                                    borderWidth: 1.0,
                                                    backgroundColor: UIColor.white,
                                                    height: 80.0,
                                                    text: "Autenticar",
                                                    textColor: UIColor.black,
                                                    font: font)
        guard let viewModel = TSQBioAuthViewModel(reason: "this is the reason",
                                                  firstButtonConfig: firstButtonConfig,
                                                  secondButtonConfig: secondButtonConfig) else {
            return
        }
        guard let viewController = TSQBioAuthViewController.create(viewModel: viewModel) as? TSQBioAuthViewController else {
            return
        }
        self.present(viewController, animated: true, completion: nil)
    }
}

